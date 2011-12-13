module PublicTimelineCacheModule

  class PublicTimelineProxy < RedisBaseProxy
    def initialize
      @key = "all_public_feeds"
    end

    def xxxs_ids_db
      Feed.publics_db.map{|f|f.id}
    end

    def self.add_feed_cache(feed)
      public_collections = feed.collections.select {|collection| collection.public? }
      feed_is_public = !public_collections.blank? # 只要有一个公开收集册，就认为feed是公开的

      PublicTimelineProxy.new.add_to_cache_and_sort(feed.id) if feed_is_public
    end
  end

  class LogicRules
    def self.rules
      {
        :class => Feed ,
        :after_save => Proc.new {|feed|
          PublicTimelineProxy.add_feed_cache(feed)
        },
        :after_destroy => Proc.new {|feed|
          PublicTimelineProxy.new.remove_from_cache(feed.id)
        }
      }
    end

    def self.funcs
      []
    end
  end
  
end
