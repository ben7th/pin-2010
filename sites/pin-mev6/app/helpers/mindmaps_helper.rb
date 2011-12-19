module MindmapsHelper
  # 在页面上显示导图缩略图固定120x120尺寸，会被js lazy load
  def mindmap_thumb(mindmap)
    mindmap_image(mindmap,'120x120')
  end

  # 在页面上显示导图某尺寸缩略图，会被js lazy load
  # 12月11日 由于环境迁移 EXT3 文件系统单一目录下子目录数量有限制，因此
  # 分多个文件夹
  def mindmap_image(mindmap, size_param)
    src = mindmap.thumb_image_url(size_param)
    
    "<img alt='#{h mindmap.title}' src='#{src}' />"
  end

  def escape_title(mindmap,size = nil)
    if size.nil?
      return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end

  def escape_title(mindmap,size = nil)
    if size.nil?
     return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end

  include MindmapRightsHelper
end
