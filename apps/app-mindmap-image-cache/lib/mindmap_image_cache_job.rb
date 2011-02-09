class MindmapImageCacheJob < Struct.new(:mindmap_id,:size)
  def perform
    mindmap = Mindmap.find(mindmap_id)
    MindmapImageCache.new(mindmap).refresh_cache_file(size)
  end
end
