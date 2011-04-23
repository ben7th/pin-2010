class FeedsOfMindmapProxy < RedisBaseProxy

  def initialize(mindmap)
    @mindmap = mindmap
    @key = "mindmap_#{@mindmap.id}_feeds_id"
  end

  def xxxs_ids_db
    @mindmap.reload.feeds_db.map{|feed|feed.id}
  end

  def self.rules
    {
      :class=>FeedMindmap,
      :after_create => Proc.new {|feed_mindmap|
        feed,mindmap = feed_mindmap.feed,feed_mindmap.mindmap
        FeedsOfMindmapProxy.new(mindmap).add_to_cache(feed.id)
      },
      :after_destroy => Proc.new{|feed_mindmap|
        feed,mindmap = feed_mindmap.feed,feed_mindmap.mindmap
        FeedsOfMindmapProxy.new(mindmap).remove_from_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class => Mindmap,
      :feeds => Proc.new {|mindmap|
        FeedsOfMindmapProxy.new(mindmap).get_models(Feed)
      }
    }
  end

end
