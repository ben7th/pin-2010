class ImageCacheJsonMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/\/(\w+)\.json\?size=(\w+x\w+)&domid=(\w+)/}
  end


  def self.deal(hash)
    env = hash[:env]
    url_match = hash[:url_match]
    jsonp_name = env["rack.request.query_hash"]["mindmap_image_cache_callback"]
    mindmap_id = url_match[1]
    size = url_match[2]
    dom_id = url_match[3]
    mindmap = Mindmap.find_by_id(mindmap_id)
    image_src = MindmapImageUrlRedisCache.new.get_cached_url(mindmap,size)
    loaded = !!image_src
    if !loaded
      MindmapImageCacheQueueWorker.async_mindmap_image_cache(mindmap.id,size)
    end
    hash_tmp = {
      "map_id"=>mindmap_id,
      "dom_id"=>dom_id,
      "size"=>size,
      "image_src"=>image_src,
      "loaded"=>loaded,
      "updated_at"=>mindmap.updated_at.to_i
    }
    str = %~#{jsonp_name}(#{hash_tmp.to_json})~
    return [200, {"Content-Type" => "text/json"}, [str]]
  rescue Exception => ex
    puts ex.backtrace*"\n"
    puts ex.message
  end



end
