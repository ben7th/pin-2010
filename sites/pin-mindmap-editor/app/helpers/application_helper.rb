# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def isIE
    /MSIE 6/.match(request.user_agent)
  end
  
  def isFF
    /Firefox/.match(request.user_agent)
  end
  
  # utf8下将中文当成两个字符处理的自定义的truncate方法
  # 取自javaeye上庄表伟和quake wang的方法
  # 由于quake wang的方法在需要截取的字符数大于30时有较严重的效率问题，导致卡死进程
  # 因此需要截取长度大于30时使用庄表伟的方法
  def truncate_u(text, length = 30, truncate_string = "...")
     if length >= 30
        l=0
        char_array=text.unpack("U*")
        char_array.each_with_index do |c,i|
          l = l+ (c<127 ? 0.5 : 1)
          if l>=length
            return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
          end
        end
        return text
     else
       if r = Regexp.new("(?:(?:[^\xe0-\xef\x80-\xbf]{1,2})|(?:[\xe0-\xef][\x80-\xbf][\x80-\xbf])){#{length}}", true, 'n').match(text)
           return r[0].length < text.length ? r[0] + truncate_string : r[0]
       else
           return text
       end
     end
  end
  
  # 摘要
  def brief(text)
    "　　"<<h(truncate_u(text,28))
  end
  
  # 对纯文本字符串进行格式化，增加中文段首缩进，以便于阅读
  def group_content_format(content)
    simple_format(h(content)).gsub("<p>", "<p>　　").gsub("<br />","<br />　　")
  end
  
  def rate_str(rater)
    rater.rate_average==0 ? "未评分":"平均 #{rater.rate_average} 分"
  end

  # 这里有bug 有html代码混入的话会乱掉
  def get_visable_name(model)
    begin
      model.name.gsub("'","")
    rescue NoMethodError
      model.title.gsub("'","")
    end
  end
  
  # 无链接的logo
  def logo(model,style=nil)
    style_str = style.nil? ? '':"_#{style}"
    unless model.blank?
      "<img alt='' class='logo #{style}' id='logo_#{dom_id(model)}#{style_str}' src='#{model.logo.url(style)}'/>"
    else
      "<img alt='' class='logo #{style}' src='/images/logo/default_unknown.png'/>"
    end
  end

  def logoss(model)
    unless model.blank?
      "<img alt='' class='logo' src='#{model.logo.url}'/>"
    else
      "<img alt='' class='logo' src='/images/logo/default_unknown.png'/>"
    end
  end

  # 快速链接
  def qlink(model,options = {})
    if model.blank?
      return "<span style='color:#999;'>[已删除]</span>"
    end
    begin
      name=model.name
    rescue NoMethodError
      name=model.title
    end
    link_to h(name),model,options
  end
  
  # user快速链接
  def ulink(user)
      link_to h(current_user==user ? '您' : user.name),user
  end
  
  # user数组快速链接
  def ulinks(users)
    users.map{|u| ulink u}.join(', ')
  end

  # 带链接的user logo
  def user_logo_link(user)
    link_to logo(user),user,:title=>"查看#{user.name}的档案"
  end
  
  def mindmap_logo_link(mindmap)
    link_to logoss(mindmap),mindmap,:title=>"查看#{pinamp.title}"
  end
  
  # user logo&name的标签
  def user_label(user)
    "<dl class='pinu'><dt>#{user_logo_link user}</dt><dd>#{qlink user}</dd></dl>"
  end
  
  # 给当前页增加RSS FEED链接
  def rssfeed
    link_to "<img src='/images/rss.png' style='vertical-align:text-bottom'>","#{request.url.sub(/\/$/,"")}.rss"
  end
  
  # 计算回复数 如果没有回复则为空
  def count_reply(size)
    size>1?size-1:''
  end
  
  # 以中文式引号围绕
  def cn_quote(str)
    "<img src='/images/s.gif' class='quote-left'/>#{str}<img src='/images/s.gif' class='quote-right'/>"
  end
  
  # 搜索结果高亮字符串转义
  def h_highlight(str)
    (h str).gsub('&lt;span class=&quot;highlight&quot;&gt;','<span class="highlight">').gsub('&lt;/span&gt;','</span>')
  end
  
  # 获取被访问次数
  def visitcount(resource)
    if resource.visit_counter.blank?
      return "<span>0</span>"
    else
      return "<span>#{resource.visit_counter.visit_count}</span>"
    end
  end
  
  def visitcountstr(resource)
    if resource.visit_counter.blank?
      return "<span class='quiet'>未被浏览</span>"
    else
      return "<span class='quiet'>浏览#{resource.visit_counter.visit_count}次</span>"
    end
  end
  
  # 生成圆角文本块
  def roundcorner(string , options = {})
    re="<div class='#{options[:color]||'rc-light-green'}' style='#{options[:style]}'>"
    re+="<span class='lt'><span class='rt'><span class='rb'><span class='lb #{options[:textclass]}' style='#{options[:textstyle]}'>"
    re+=string
    re+='</span></span></span></span></div>'
  end
  
  def rch3(string,options = {})
    roundcorner string,:color=>"rc-light-green",:style=>"margin:10px 0 5px;zoom:1;",:textclass=>"rc-title"
  end
  
  def block_title(title,link = nil)
    re=[]
    re.push '<div style="overflow:hidden;clear:both;">'
    re.push "<div style='float:left'>#{rch3 title}</div>"
    re.push "<div style='float:left;margin:12px 0 0 5px;'>#{link.blank? ? "" : link_to("[...更多]",link)}</div>"
    re.push '</div>'
    re*''
  end
  
  # 生成mindmap列表细节显示级别选择器链接
  def detail_link(req_uri,level)
    uri=req_uri.clone.dup
    unless (uri.sub!(%r!((?:\?|\&)detail=)(\d+)!,'\1'+level.to_s)).nil?
      uri
    else
      if uri.match(/\?/)
        "#{uri}&detail=#{level}"  
      else
        "#{uri}?detail=#{level}"
      end
    end
  end
  
  # 生成mindmap列表排序方式选择器链接
  def sort_link(req_uri,level)
    uri=req_uri.clone.dup
    unless (uri.sub!(%r!((?:\?|\&)sortby=)(\d+)!,'\1'+level.to_s)).nil?
      uri
    else
      if uri.match(/\?/)
        "#{uri}&sortby=#{level}"
      else
        "#{uri}?sortby=#{level}"
      end
    end
  end
  
  #i 原始数 n 要保留的小数位数，flag=1 四舍五入 flag=0 不四舍五入   
  def _4s5r(i,n=2,flag=1) 
    i = i.to_f
    y = 1
    n.times do |x|
      y = y*10
    end
    if flag==1
      (i*y).round/(y*1.0)
    else
      (i*y).floor/(y*1.0)
    end
  end
end
