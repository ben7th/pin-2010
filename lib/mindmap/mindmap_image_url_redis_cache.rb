=begin
key : mindmap_image_url_cache

value 是个hash
   #{mindmap_id}_#{size}=>{:timestamp=>xxx,:url=>url}
=end
class MindmapImageUrlRedisCache
  def initialize
    @key = "mindmap_image_url_cache"
    @mindmap_image_redis_cache = RedisHash.new(@key)
  end

  # 设置一个缓存
  def set_cache(mindmap,size,url)
    key = "#{mindmap.id}_#{size}"
    value = {:timestamp=>mindmap.updated_at.to_i,:url=>url}
    @mindmap_image_redis_cache.set(key,value)
  end

  # 取到 一个 mindmap 的 size 尺寸的 缓存 url
  def get_cached_url(mindmap,size)
    begin
      key = "#{mindmap.id}_#{size}"
      value = @mindmap_image_redis_cache.get(key)
      return if value.blank? || mindmap.updated_at.to_i > value["timestamp"].to_i
      return value["url"]
    rescue Exception => ex
      p '获取缩略图缓存地址时发生异常'
      p ex
      p value
      return ''
    end
  end
  
  def clear_cache(mindmap,size)
    key = "#{mindmap.id}_#{size}"
    @mindmap_image_redis_cache.remove(key)
  end

  def del
    @mindmap_image_redis_cache.del
  end

end
