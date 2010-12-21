require "pie-service-lib"
class ImageCacheMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/(\w+)\.(([\w\.]+)\.)?(png|jpg|jpeg|gif|bmp)/}
  end

  def self.deal(hash)
    env = hash[:env]
    url_match = hash[:url_match]
    
    mindmap_id = url_match[1]
    size = url_match[3] || "1"

    mindmap = Mindmap.find(mindmap_id)
    last_modified_at = mindmap.updated_at

    if not_modified?(last_modified_at,env)
      return [304, {"Content-Type" => "image/png"}, ['Not Modified']]
    else
      img_path = find_img_path_by_size(size,mindmap)
      image_file = File.open(img_path)
      return [200, {"Content-Type" => "image/png", "Last-Modified" => last_modified_at.httpdate}, [image_file.read]]
    end
  ensure
    image_file.close if image_file
  end

  # 当 size 是 thumb 时，按是否私有返回不同图片
  # 当 size 是 非 thumb 时，返回导图内容图片
  def self.find_img_path_by_size(size,mindmap)
    if size == "thumb" && mindmap.private
      return "#{RAILS_ROOT}/public/images/private_map.png"
    end
    _size = size
    _size = "120x90" if size == "thumb"
    mindmap.get_img_path_by(_size)
  end

  def self.if_modified_since(env)
    if since = env['HTTP_IF_MODIFIED_SINCE']
      Time.rfc2822(since) rescue nil
    end
  end

  def self.not_modified?(modified_at,env)
    since = self.if_modified_since(env)
    since && modified_at && since.to_i >= modified_at.to_i
  end
  
end
