class MindmapImageCacheQueueWorker

  @queue = :mindmap_image_cache_queue_worker

  def self.async_mindmap_image_cache(mindmap_id, size)
    Resque.enqueue(MindmapImageCacheQueueWorker, mindmap_id, size)
  end

  def self.perform(mindmap_id, size)
    mindmap = Mindmap.find(mindmap_id)
    MindmapImageCache.new(mindmap).refresh_cache_file(size)
    image_src = self.get_image_src(mindmap_id,size)
    MindmapImageUrlRedisCache.new.set_cache(mindmap,size,image_src)
  end

  def self.get_image_src(mindmap_id,size)
    if RAILS_ENV == "production"
      "http://mindmap-image-cache-#{rand(10)}.mindpin.com/#{mindmap_id}.#{size}.png"
    else
      "http://dev.mindmap-image-cache-#{rand(10)}.mindpin.com/#{mindmap_id}.#{size}.png"
    end
  end

end
