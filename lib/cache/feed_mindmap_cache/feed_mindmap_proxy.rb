class FeedMindmapProxy
  def initialize(feed,mindmap)
    @feed = feed
    @mindmap = mindmap
  end

  # 增加
  def add_redis_cache
    MindmapsOfFeedProxy.new(@feed).add_to_cache(@mindmap.id)
    FeedsOfMindmapProxy.new(@mindmap).add_to_cache(@feed.id)
  end

  # 删除
  def delete_redis_cache
    MindmapsOfFeedProxy.new(@feed).remove_from_cache(@mindmap)
    FeedsOfMindmapProxy.new(@mindmap).remove_from_cache(@feed)
  end

  module FeedMindmapsMethods
    def self.included(base)
      base.after_create :add_feed_mindmaps_proxy
      base.after_destroy :destroy_feed_mindmaps_proxy
    end

    def add_feed_mindmaps_proxy
      FeedMindmapProxy.new(feed,mindmap).add_redis_cache
    end

    def destroy_feed_mindmaps_proxy
      FeedMindmapProxy.new(feed,mindmap).delete_redis_cache
    end
  end

  module FeedMethods
    def mindmaps
      MindmapsOfFeedProxy.new(self).xxxs_ids.map{|id|Mindmap.find_by_id(id)}
    end
  end

  module MindmapMethods
    def feeds
      FeedsOfMindmapProxy.new(self).xxxs_ids.map{|id|Feed.find_by_id(id)}
    end
  end
end
