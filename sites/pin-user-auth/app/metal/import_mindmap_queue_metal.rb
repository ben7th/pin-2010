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
    image_src = (loaded && success) ? "http://dev.mindmap-image-cache-#{rand(10)}.mindpin.com/#{mindmap_id}.450x338.png" : nil
    hash_tmp = {
      "map_id"=>mindmap_id,
      "map_title"=>mindmap_title,
      "success"=>success,
      "image_src"=>image_src,
      "loaded"=>loaded,
    }
    str = %~#{jsonp_name}(#{hash_tmp.to_json})~
    return [200, {"Content-Type" => "text/json"}, [str]]
  rescue Exception => ex
    puts ex.backtrace*"\n"
    puts ex.message
  end

end
