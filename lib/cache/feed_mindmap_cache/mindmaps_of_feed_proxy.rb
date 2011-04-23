class MindmapsOfFeedProxy < RedisBaseProxy

  def initialize(feed)
    @feed = feed
    @key = "feed_#{@feed.id}_mindmaps_id"
  end

  def xxxs_ids_db
    @feed.reload.mindmaps_db.map {|mindmap|mindmap.id}
  end

  def self.rules
    {
      :class=>FeedMindmap,
      :after_create => Proc.new {|feed_mindmap|
        feed,mindmap = feed_mindmap.feed,feed_mindmap.mindmap
        MindmapsOfFeedProxy.new(feed).add_to_cache(mindmap.id)
      },
      :after_destroy => Proc.new{|feed_mindmap|
        feed,mindmap = feed_mindmap.feed,feed_mindmap.mindmap
        MindmapsOfFeedProxy.new(feed).remove_from_cache(mindmap)
      }
    }
  end

  def self.funcs
    {
      :class => Feed,
      :mindmaps => Proc.new {|feed|
        MindmapsOfFeedProxy.new(feed).get_models(Mindmap)
      }
    }
  end

end
