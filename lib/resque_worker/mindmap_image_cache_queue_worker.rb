class MindmapImageCacheQueueWorker
  QUEUE = :mindmap_image_cache_resque_queue
  @queue = QUEUE

  def self.async_mindmap_image_cache(mindmap)
#    jobs = Resque.peek(QUEUE,0,Resque.size(QUEUE))
#    jobs = [jobs].flatten
#    return if jobs.map{|job|job["args"]}.include?([mindmap_id,size])
    return if mindmap.id.blank?
    time = mindmap.updated_at.to_f.to_s
    Resque.enqueue(MindmapImageCacheQueueWorker, mindmap.id,time)
  end

  def self.perform(mindmap_id, time)
    return true if mindmap_id == "wake_up"
    mindmap = Mindmap.find(mindmap_id)
    updated_at = Time.at(time.to_f)
    return if updated_at < mindmap.updated_at

    MindmapImageCache.new(mindmap).refresh_cache_file("120x120")
    MindmapImageCache.new(mindmap).refresh_cache_file("500x500")
  end

end
