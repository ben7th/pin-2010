require "pie-service-lib"
class ImageCacheMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/images\/(.+).(png|jpg|jpeg|gif|bmp)/}
  end

  def self.deal(hash)
    url_match = hash[:url_match]
    mindmap_id = url_match[1]
    env = hash[:env]
    size = Rack::Request.new(env).params["size_param"] || 1

    mindmap = Mindmap.find(mindmap_id)    
    last_modified_at = mindmap.updated_at

    if not_modified?(last_modified_at,env)
      return [304, {"Content-Type" => "image/png"}, ['Not Modified']]
    else
      img_path = mindmap.get_img_path_by(size)
      image_file = File.open(img_path)

      return [200, {"Content-Type" => "image/png", "Last-Modified" => last_modified_at.httpdate}, [image_file.read]]
   end
  ensure
    image_file.close if image_file
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
