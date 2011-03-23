class FeedsOfMindmapProxy < RedisBaseProxy

  def initialize(mindmap)
    @mindmap = mindmap
    @key = "mindmap_#{@mindmap.id}_feeds_id"
  end

  def xxxs_ids_db
    @mindmap.reload.feeds_db.map{|feed|feed.id}
  end

end
