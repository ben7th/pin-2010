module MpmlUrl
  def replace_url
    replace_link_url
    replace_img_url
    replace_css_url
    replace_form_url
    replace_embed_url
  end

  # 替换链接地址
  def replace_link_url
    doc.css('a').each do |el|
      href = el['href']
      raise "MPML解析错误：链接没有href属性 #{el.parent}" if href.blank?
      if(href.at(0)=='/')
        href = "#{APP_PREFIX}#{app.name}#{href}"
        href = href.remove_mindpin_token
        el['href']= href
      end
    end
  end
  
  # 替换图片地址
  def replace_img_url
    doc.css('img').each do |el|
      src = el['src']
      if(!src.blank? && src.at(0)=='/' && !src.match("/#{app.name}"))
        el['src'] = "http://#{app_url}#{src}"
      end
    end
  end

  # 替换css地址
  def replace_css_url
    doc.css('link').each do |el|
      href = el['href']
      if(href.at(0)=='/')
        el['href'] = "http://#{app_url}#{href}"
      end
    end
  end

  # 替换表单地址
  def replace_form_url
    doc.css('form').each do |el|
      action = el['action']
      if(action.at(0)=='/')
        action = "#{APP_PREFIX}#{app.name}#{action}"
        el['action'] = action
      end
    end
  end

  # 替换embed地址
  def replace_embed_url
    doc.css('embed').each do |el|
      src = el['src']
      if(src.at(0)=='/')
        el['src'] = "http://#{app_url}#{src}"
      end
    end
  end
end
