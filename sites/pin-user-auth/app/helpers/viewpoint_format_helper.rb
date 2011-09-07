module ViewpointFormatHelper
  # 评论
  def comment_content(comment)
    str = h comment.content
    str.gsub(MindpinTextFormat::AT_REG) do
      "<a href='/atmes/#{$1}'>@#{$1}</a>"
    end
  end

  # 主题
  #-----------------

  def feed_title(feed)
    "#{h(feed.title)}"
  end

  def feed_title_short(feed,length=16)
    "#{h(truncate_u(feed.title,length))}"
  end

  def feed_detail(feed)
    detail = feed.detail || ''
    main_post = feed.main_post

    html = case main_post.text_format
    when Post::FORMAT_HTML
      detail
    when Post::FORMAT_MARKDOWN
      MindpinTextFormat.new(detail).to_html
    end

    find_and_preserve html
  end

  def feed_detail_short(feed)
    detail = feed.detail || ''
    text_str = MindpinTextFormat.new(detail).to_text
    find_and_preserve "#{h(truncate_u(text_str,256))}"
  end

  

  # 观点
  # -----------
  def viewpoint_memo_format_show(vp)
    find_and_preserve MindpinTextFormat.new(vp.memo).to_html
  end

  def viewpoint_memo_format_in_list(vp)
    s1 = _viewpoint_memo_format_in_list_short(vp)
    s2 = _viewpoint_memo_format_in_list_long(vp)

    if s1.length == s2.length
      re = s1
    else
      re = %~
        <div class='short-content'>#{s1} <a href='javascript:;' class='show-detail font12'>显示全部</a></div>
        <div class='detail-content' style='display:none;'>#{s2}</div>
      ~
    end

    find_and_preserve re
  end

  def _viewpoint_memo_format_in_list_long(vp)
    h MindpinTextFormat.new(vp.memo).to_text
  end

  def _viewpoint_memo_format_in_list_short(vp)
    h truncate_u(MindpinTextFormat.new(vp.memo).to_text, 64)
  end
end
