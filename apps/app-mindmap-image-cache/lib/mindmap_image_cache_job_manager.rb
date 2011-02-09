class MindmapImageCacheJobManager
  def initialize(mindmap_id,size)
    @micj = MindmapImageCacheJob.new(mindmap_id,size)
    @yaml = @micj.to_yaml
  end

  def start
    job = Delayed::Backend::ActiveRecord::Job.find_by_handler(@yaml)
    if job.blank?
      Delayed::Job.enqueue @micj
    end
  end
end
