module MpmlNav
  def parse_nav
    doc.css('mp|nav').each do |nav|
      rename nav,'ul'
      nav['class'] = 'tab-control'
      nav.css('mp|ni').each do |ni|
        active = ni['active'] == 'true'
        rename ni,'li'
        ni['class'] = ["tab-control-li",active ? 'tab-selected':'']*' '
        href = ni.delete 'href'
        if(!href.blank? && href.to_s.at(0)=='/')
          href = "/app/#{app.name}#{href}"
        end
        text = ni.text
        ni.inner_html = "<a href='#{href}'>#{text}</a>"
      end
    end
  end

  def parse_finder
    finders = doc.css('mp|finder')
    finders.each do |f|
      key = f['key']
      title = f['title']
      clazz = f['class']
      
      ul_str = ''
      f.css('mp|fi').each do |fi|
        value = fi['value']
        name = fi.inner_html
        default = (fi['default']=='true')
        ul_str += "<li id='fi-#{key}-#{value}'>#{finder_link(name,key,value,default)}</li>"
      end

      f.after("<div id='finder-#{key}' class='#{clazz}'><span>#{title}</span><ul>#{ul_str}</ul></div>")
    end
    finders.remove
  end

  def finder_link(name,key,value,default=false)
    # 检查url里面是否包含当前条件
    if(include_query?(key,value))
      # 如果完整包含当前条件 key=value 则返回selected
      "<a href='#{finder_url(key,value)}' class='selected'>#{name}</a>"
    elsif(!include_query_key?(key)&&default)
      # 或者不包含当前key，且当前value是默认值，也返回selected
      "<a href='#{finder_url(key,value)}' class='selected'>#{name}</a>"
    else
      "<a href='#{finder_url(key,value)}'>#{name}</a>"
    end
  end

  include LinkHelper
end
