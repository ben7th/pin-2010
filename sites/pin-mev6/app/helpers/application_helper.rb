module ApplicationHelper
  include MindpinHelperBase
  
  # 侧边栏导航
  def daotu_sub_menu_li(name, path, options={})
    o_klass = options[:class] || ''

    if current_page?(path)
      klass = [o_klass, 'i-am-here'] * ' '
    else
      klass = o_klass
    end

    return link_to(content_tag(:span, name), path, :class=>klass)
  end
end
