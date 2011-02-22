class MindmapImageCacheRedisQueue
  def initialize
    @key = "mindmap_image_cache_redis_queue"
    @redis = RedisCache.instance
  end

  # 从队列头弹出一个消息
  def pop
    @redis.rpop(@key)
  end

  # 把 value 放入队列
  # push之前要先 检查队列里面是否已经存在了这个值
  def push(mindmap_id,size)
    value = "#{mindmap_id}_#{size}"
    return if all.include?(value)
    @redis.lpush(@key,value)
  end

  def all
    @redis.lrange(@key,0,-1)
  end

  def get
    all[-1]
  end

  def delete(value)
    @redis.lrem(@key,-1,value)
  end

  def self.update_first_item_cache_image
    micrq = MindmapImageCacheRedisQueue.new
    a_cache_image = micrq.get
    return false if a_cache_image.blank?
    a_cache_image_data = a_cache_image.split("_")
    mindmap_id = a_cache_image_data[0]
    size = a_cache_image_data[1]
    mindmap = Mindmap.find(mindmap_id)
    MindmapImageCache.new(mindmap).refresh_cache_file(size)
    image_src = self.get_image_src(mindmap_id,size)
    MindmapImageUrlRedisCache.new.set_cache(mindmap,size,image_src)
    micrq.delete(a_cache_image)
    return true
  end

  def self.get_image_src(mindmap_id,size)
    if RAILS_ENV == "production"
      "http://mindmap-image-cache-#{rand(10)}.mindpin.com/#{mindmap_id}.#{size}.png"
    else
      "http://dev.mindmap-image-cache-#{rand(10)}.mindpin.com/#{mindmap_id}.#{size}.png"
    end
  end

end
