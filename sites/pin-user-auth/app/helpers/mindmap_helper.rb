module MindmapHelper
  def mindmap_thumb(mindmap)
    @mindmap_image_cache_asset_num ||= 0
    str = "<img src='http://dev.mindmap-image-cache-#{@mindmap_image_cache_asset_num}.mindpin.com/#{mindmap.id}.thumb.png' alt='#{mindmap.title}' />"
    @mindmap_image_cache_asset_num = (@mindmap_image_cache_asset_num + 1) % 10
    str
  end

  def mindmap_image(mindmap,size_param)
    @mindmap_image_cache_asset_num ||= 0
    str = "<img src='http://dev.mindmap-image-cache-#{@mindmap_image_cache_asset_num}.mindpin.com/#{mindmap.id}.#{size_param}.png' alt='#{mindmap.title}' />"
    @mindmap_image_cache_asset_num = (@mindmap_image_cache_asset_num + 1) % 10
    str
  end
end
