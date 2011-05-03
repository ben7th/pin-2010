class ImageCacheJsonMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/\/(\w+)\.json\?size=(\w+x\w+)&domid=(\w+)/}
  end


  def self.deal(hash)
    0/0
    env = hash[:env]
    url_match = hash[:url_match]
    jsonp_name = env["rack.request.query_hash"]["mindmap_image_cache_callback"]

    mindmap_id,size,dom_id = url_match[1], url_match[2], url_match[3]

    mindmap = Mindmap.find_by_id(mindmap_id)
    image_src = MindmapImageUrlRedisCache.new.get_cached_url(mindmap,size)

    loaded = !!image_src
    if !loaded
      # 如果没有加载，把请求放入队列
      MindmapImageCacheQueueWorker.async_mindmap_image_cache(mindmap.id,size)
    end

    loaded_data_hash = {
      "map_id"=>mindmap_id,
      "dom_id"=>dom_id,
      "size"=>size,
      "image_src"=>image_src,
      "loaded"=>loaded,
      "updated_at"=>mindmap.updated_at.to_i
    }
    
    str = "#{jsonp_name}(#{loaded_data_hash.to_json})"
    return [200, {"Content-Type" => "text/json"}, [str]]
  rescue Exception => ex
    error_msg = %~
      #{ex}
      #{ex.message}
      #{ex.backtrace*"\n"}
    ~
    puts error_msg
    return [500, {"Content-Type" => "text/html"}, [error_msg]]
  end



end
