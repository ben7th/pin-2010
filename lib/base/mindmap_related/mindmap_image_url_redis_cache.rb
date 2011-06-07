=begin
key : mindmap_image_url_cache

value 是个hash
   #{mindmap_id}_#{size}=>{:timestamp=>xxx,:url=>url}
=end
class MindmapImageUrlRedisCache
  def initialize
    @key = "mindmap_image_url_cache"
    @mindmap_image_redis_cache = RedisCacheHash.new(@key)
  end

  # 指定一个导图的size，url，设置一个缓存
  def set_cache(mindmap,size,url)
    key = "#{mindmap.id}_#{size}"
    value = {'timestamp'=>mindmap.updated_at.to_i,'url'=>url}
    @mindmap_image_redis_cache.set(key,value)
  end

  # 尝试取到一个导图的 指定size的缓存url
  def get_cached_url(mindmap,size)
    begin
      key = "#{mindmap.id}_#{size}"
      value = @mindmap_image_redis_cache.get(key)

      if value.blank?
        # 缓存不存在
        return
      end

      if mindmap.updated_at.to_i > value['timestamp'].to_i
        # 缓存已过期
        clear_cache(mindmap,size)
        return
      end

      return value['url']
    rescue Exception => ex
      p '获取缩略图缓存地址时发生异常'
      p ex
      p value
      return
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
