module MindmapsHelper
  # 在页面上显示导图缩略图固定120x120尺寸，会被js lazy load
  def mindmap_thumb(mindmap)
    mindmap_image(mindmap,'120x120')
  end

  # 在页面上显示导图某尺寸缩略图，会被js lazy load
  # 12月11日 由于环境迁移 EXT3 文件系统单一目录下子目录数量有限制，因此
  # 导图ID > 42033 （产品环境超限的导图id）
  # 时，分多个文件夹
  def mindmap_image(mindmap, size_param)
    id = mindmap.id

    asset_id = (id / 1000).to_s
    src = pin_url_for("pin-mindmap-image-cache","/asset/#{asset_id}/#{id}.#{size_param}.png?#{mindmap.updated_at.to_i}")

    src.gsub! 'mindmap-image-cache',"mindmap-image-cache-#{id % 10}"
    "<img alt='#{h mindmap.title}' src='#{src}' />"
  end

  def mindmap_thumb_url_for_share(mindmap)
    pin_url_for("pin-mindmap-image-cache","#{mindmap.id}.500x500.png?#{mindmap.updated_at.to_i}")
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
