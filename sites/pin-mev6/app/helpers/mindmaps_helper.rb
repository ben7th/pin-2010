module MindmapsHelper
  # 在页面上显示导图缩略图固定120x120尺寸，会被js lazy load
  def mindmap_thumb(mindmap)
    mindmap_image(mindmap,'120x120')
  end

  # 在页面上显示导图某尺寸缩略图，会被js lazy load
  def mindmap_image(mindmap,size_param)
    asset_num = mindmap.id % 10
    src = pin_url_for("pin-mindmap-image-cache","#{mindmap.id}.#{size_param}.png?#{mindmap.updated_at.to_i}")
    src.gsub! 'mindmap-image-cache',"mindmap-image-cache-#{asset_num}"

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
