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
  
  # 在页面上显示导图某尺寸缩略图
  # 12月11日 由于环境迁移 EXT3 文件系统单一目录下子目录数量有限制，因此
  # 分多个文件夹
  def mindmap_image(mindmap, size_param)
    src = mindmap.thumb_image_url(size_param)
    image_tag(src, :alt=>(h mindmap.title))
  end
  
end
