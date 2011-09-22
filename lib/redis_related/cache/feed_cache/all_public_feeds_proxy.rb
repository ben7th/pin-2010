class AllPublicFeedsProxy < RedisBaseProxy
  def initialize
    @key = "all_public_feeds"
  end

  def xxxs_ids_db
    Feed.publics_db.map{|f|f.id}
  end

  def self.remove_feed_cache(feed_collection)
    feed = feed_collection.feed
    return if feed.blank?
    
    AllPublicFeedsProxy.new.remove_from_cache(feed.id)
  end

  def self.add_feed_cache(feed_collection)
    feed = feed_collection.feed
    collection = feed_collection.collection
    return if collection.blank? || feed.blank?
    return unless collection.public?

    proxy = AllPublicFeedsProxy.new
    ids = proxy.xxxs_ids
    unless ids.include?(feed.id)
      proxy.add_to_cache(feed.id)
    end
  end

  def self.rules
    {
      :class => FeedCollection ,
      :after_create => Proc.new {|feed_collection|
        AllPublicFeedsProxy.add_feed_cache(feed_collection)
      },
      :after_destroy => Proc.new {|feed_collection|
        AllPublicFeedsProxy.remove_feed_cache(feed_collection)
      }
    }
  end

  def self.funcs
    []
  end
end
