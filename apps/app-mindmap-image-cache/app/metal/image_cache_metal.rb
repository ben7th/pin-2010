class ImageCacheMetal < BaseMetal
  ETAG = "8c079a70cad7abf91332a3e087a677c"
  def self.routes
    {:method=>'GET',:regexp=>/^\/(\w+)\.(([\w\.]+)\.)?(png|jpg|jpeg|gif|bmp)/}
  end

  def self.etag_equal?(env)
    etag = env['HTTP_IF_NONE_MATCH']
    ETAG == etag
  end

  def self.if_modified_since(env)
    if since = env['HTTP_IF_MODIFIED_SINCE']
      Time.rfc2822(since) rescue nil
    end
  end

  def self.not_modified?(modified_at,env)
    since = self.if_modified_since(env)
    since && modified_at && since.to_i >= modified_at.to_i && self.etag_equal?(env)
  end

  def self.deal(hash)
    env = hash[:env]
    url_match = hash[:url_match]
    
    mindmap_id = url_match[1]
    size_param = url_match[3] || "1"
    size = size_param
    size = "120x90" if size_param == "thumb"

    mindmap = Mindmap.find(mindmap_id)
    last_modified_at = mindmap.updated_at

    # 304 缓存
    if not_modified?(last_modified_at,env)
      return [304, {"Content-Type" => "image/png"}, ['Not Modified']]
    end
    mindmap_image_cache = MindmapImageCache.new(mindmap)
    # 图片已经生成，直接获取图片路径，响应请求，给出304缓存的Last-Modified值
    img_path = find_img_path_by_size(mindmap_image_cache,size)
    image_file = File.open(img_path)
    return [200, {"Content-Type" => "image/png", "Last-Modified" => last_modified_at.httpdate,"Etag"=> ETAG}, [image_file.read]]
  rescue Exception => ex
    puts ex.backtrace*"\n"
    puts ex.message
  ensure
    image_file.close if image_file
  end

  # 当 size 是 thumb 时，按是否私有返回不同图片
  # 当 size 是 非 thumb 时，返回导图内容图片
  def self.find_img_path_by_size(mindmap_image_cache,size)
    mindmap = mindmap_image_cache.mindmap
    if size == "thumb" && mindmap.private
      return "#{RAILS_ROOT}/public/images/private_map.png"
    end
    mindmap_image_cache.img_path(size)
  end
  
end
