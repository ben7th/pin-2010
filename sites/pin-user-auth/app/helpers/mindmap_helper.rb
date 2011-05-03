module MindmapHelper
  # 在页面上显示导图缩略图固定120x120尺寸，会被js lazy load
  def mindmap_thumb(mindmap)
    mindmap_image(mindmap,'120x120')
  end

  # 在页面上显示导图某尺寸缩略图，会被js lazy load
  def mindmap_image(mindmap,size_param)
    loaded_src = MindmapImageUrlRedisCache.new.get_cached_url(mindmap,size_param)
    loading_src = pin_url_for('pin-user-auth',"/images/icons/loading-s-1.gif")
    
    str = %~
      <div id='#{randstr}' class='cached-mindmap-image' data-map-id='#{mindmap.id}' data-map-size='#{size_param}' data-updated-at='#{mindmap.updated_at.to_i}' data-loaded-src='#{loaded_src}'>
        <img class='loading' src='#{loading_src}' />
      </div>
    ~
    str
  end

  def escape_title(mindmap,size = nil)
    if size.nil?
      return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end

end
