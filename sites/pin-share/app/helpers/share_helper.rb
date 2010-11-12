module ShareHelper

  # 显示share的内容，长度大于140的时候隐藏一下，通过点击展开，收起
  def share_content(share)
    content = share.content
    if content.mb_chars.length < 140
      return %~
        <span class="content">#{share_auto_link share}</span>
      ~
    else
      return %~
        <span class="content">
          <span class="ct-brief">
            #{share_auto_link share,140}
            #{link_to "查看全部","javascript:void(0)",:onclick=>'ShowShareContent.show(this)'}
          </span>
          <span class="ct-all hide">
            #{share_auto_link share}
            #{link_to "收起","javascript:void(0)",:onclick=>'ShowShareContent.hide(this)'}
          </span>
        </span>
      ~
    end
  end

  # 分享表单中，textarea上面显示 分享对象的一些简要信息
  def shareable_brief_content(shareable)
    return "" if shareable.blank?
    case shareable
    when Share
      if shareable.shareable
        return render :partial=>"shares/meta_share",:locals=>{:share=>shareable}
      end
      return share_content(shareable)
    end
  end
  
  # 当前登录用户对于某个rssitem的感觉图标
  def rss_item_feeling_icon(rss_item)
    if logged_in?
      feel = rss_item.feel_of(current_user)
      klass = case feel
      when Feeling::GOOD then 'read-good-small'
      when Feeling::BAD then 'read-bad-small'
      else 'no-feel-small'
      end
      "<span class='#{klass} fleft'></span>"
    end
  end

  def source_share_count(shareable)
    title = text_num("原文转发",shareable.shared_count)
    %~
      <span class='marginl10' data-share='#{shareable.type}_#{shareable.id}'>
        #{link_to title, shareable }
      </span>
    ~
  end

  def share_count(shareable)
    title = text_num("转发",shareable.shared_count)
    if shareable.creator == current_user
      %~
        <span class='quiet share_count'>#{title}</span>
      ~
    else
      %~
        <span class='share_count'>
          #{link_to_remote title,
      :url=>polymorphic_url([:new,shareable,:share]),
      :method=>:get}
        </span>
      ~
    end
  end

  def mindmap_thumb(share)
    str = ""
    share.mindmap_urls.each do |thumb,big|
      str << %`
      <div class="boxfix margint5">
        <div class="fleft">
          #{
      link_to(image_tag(thumb,:class=>'logo b2'),big,:target=>"_blank")
          }
        </div>
      </div>
      `
    end
    str
  end
end

def bugs_content(share)
  str = ""
  share.bugs_urls.each do |content,url|
    str << %`
        <div class="font12 quiet ">
          <span>#{truncate(content,140)}<span>
          #{link_to("查看",url,:target=>"_blank")}
        </div>
    `
  end
  str
end

def share_auto_link(share,*args)
  text = share.content
  length = text.mb_chars.length

  if args[0]
    length = args[0]
    text = truncate(text,length)
  end

  html_options = {:target => "_blank"}

  re = %r{
      ( https?:// )
      [^\"\'\s<]+
  }x
  link_attributes = html_options.stringify_keys
  text.gsub(re) do

    # 把链接转换成 a 标签
    href = $&
    left, right = $`, $'

    is_intercept = false
    str = left
    str << href
    if str.mb_chars.length == length && length != share.content.mb_chars.length
      is_intercept = true
    end

    if is_intercept
      $&
    else
      # 给链接后边增加类型 视频? 音乐?
      url = ShortUrl.original_url(href)
      kind = share.url_kind(url)
      kind_span = ""
      if kind == Using::AUDIO
        kind_span = content_tag(:span,"",:class=>"audio-icon inlineicon")
      end
      if kind == Using::VIDEO
        kind_span = content_tag(:span,"",:class=>"video-icon inlineicon")
      end

      link_text = block_given?? yield(href) : href
      href = 'http://' + href unless href.index('http') == 0
      a = content_tag(:a, h(link_text), link_attributes.merge('href' => href))
      a + kind_span
    end
  end
end
