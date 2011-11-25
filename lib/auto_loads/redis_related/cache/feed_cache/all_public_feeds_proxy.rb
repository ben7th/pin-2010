class AllPublicFeedsProxy < RedisBaseProxy
  def initialize
    @key = "all_public_feeds"
  end

  def xxxs_ids_db
    Feed.publics_db.map{|f|f.id}
  end

  def self.remove_feed_cache(feed_collection)
    feed = feed_collection.feed
    collection = feed_collection.collection
    return if feed.blank? || collection.blank?
    collections = feed.collections-[collection]

    arr = collections.map do |coll|
      coll.public?
    end.select{|p|p==true}

    if arr.blank?
      AllPublicFeedsProxy.new.remove_from_cache(feed.id)
    end
  end

  def self.add_feed_cache(feed_collection)
    feed = feed_collection.feed
    collection = feed_collection.collection
    return if collection.blank? || feed.blank?
    return unless collection.public?

    proxy = AllPublicFeedsProxy.new
    ids = proxy.xxxs_ids
    unless ids.include?(feed.id)
      ids = ids.unshift(feed.id).uniq
      ids = ids.sort{|id1,id2|id2<=>id1}
      proxy.send(:send,:xxxs_ids_rediscache_save,ids)
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
