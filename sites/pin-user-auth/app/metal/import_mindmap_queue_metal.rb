class ImportMindmapQueueMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/\/import_mindmap_queue\?qid=(\w+)&\w+/}
  end


  def self.deal(hash)
    env = hash[:env]
    url_match = hash[:url_match]
    jsonp_name = env["rack.request.query_hash"]["import_mindmap_callback"]
    qid = url_match[1]
    result = ImportMindmapQueue.new.import_result(qid)
    loaded = result["loaded"]
    success = result["success"]
    mindmap_id = result["id"]
    mindmap = Mindmap.find_by_id(mindmap_id)
    mindmap_title = !!mindmap ? mindmap.title : nil
    updated_at = !!mindmap ? mindmap.updated_at.to_i : 0
    size = "120x120"
    loading_src = mindmap_image_cache_url("images/loading.gif")
    image_src = (loaded && success) ? mindmap_image_cache_url("#{mindmap_id}.#{size}.png",rand(10)) : nil
    hash_tmp = {
      "map_id"=>mindmap_id,
      "updated_at"=>updated_at,
      "size"=>size,
      "map_title"=>mindmap_title,
      "success"=>success,
      "loading_src"=>loading_src,
      "image_src"=>image_src,
      "loaded"=>loaded,
      "image_cache_url"=>mindmap_image_cache_url
    }
    str = %~#{jsonp_name}(#{hash_tmp.to_json})~
    return [200, {"Content-Type" => "text/json"}, [str]]
  rescue Exception => ex
    puts ex.backtrace*"\n"
    puts ex.message
  end

end
