module MindmapHelper
  def mindmap_thumb(mindmap)
    mindmap_image(mindmap,'120x120')
  end

  def mindmap_image(mindmap,size_param)
    @mindmap_image_cache_asset_num ||= 0
    dom_id = randstr
    map_id = mindmap.id
    updated_at = mindmap.updated_at.to_i
    src = MindmapImageUrlRedisCache.new.get_cached_url(mindmap,size_param)
    loading_src = RAILS_ENV=="production" ? "http://mindmap-image-cache.mindpin.com/images/loading.gif" : "http://dev.mindmap-image-cache.mindpin.com/images/loading.gif"
    str = %~
      <div id="#{dom_id}" class='cache_mindmap_image' data-map-id="#{map_id}" data-map-size=#{size_param} data-updated-at=#{updated_at} data-loaded-src=#{src}>
        <img class='loading' src=#{loading_src} />
      </div>
    ~
    @mindmap_image_cache_asset_num = (@mindmap_image_cache_asset_num + 1) % 10
    str
  end

  def escape_title(mindmap,size = nil)
    if size.nil?
      return CGI.escapeHTML(mindmap.title)
    end
    CGI.escapeHTML(truncate_u(mindmap.title,size))
  end
end
