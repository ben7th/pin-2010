class MindmapsOfFeedProxy < RedisBaseProxy

  def initialize(feed)
    @feed = feed
    @key = "feed_#{@feed_id}_mindmaps_id"
  end

  def xxxs_ids_db
    @feed.reload.mindmaps_db.map {|mindmap|mindmap.id}
  end

end
