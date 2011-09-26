class CollectionMixedFeedsProxy < RedisBaseProxy
  def initialize(collection)
    @collection = collection
    @key = "collection_#{collection.id}_mixed_feeds"
  end

  def xxxs_ids_db
    @collection.mixed_feeds_db.map{|x|x.id}
  end

  def self.add_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    return if feed.main_post.post_photos.blank?
    return if feed.main_post.detail.blank?
    CollectionMixedFeedsProxy.new(coll).add_to_cache(feed.id)
  end

  def self.remove_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    CollectionMixedFeedsProxy.new(coll).remove_from_cache(feed.id)
  end

  def self.rules
    {
      :class => FeedCollection ,
      :after_create => Proc.new {|feed_collection|
        CollectionMixedFeedsProxy.add_feed_cache(feed_collection)
      },
      :after_destroy => Proc.new {|feed_collection|
        CollectionMixedFeedsProxy.remove_feed_cache(feed_collection)
      }
    }
  end

  def self.funcs
    {
      :class=>Collection,
      :mixed_feeds=>Proc.new{|collection|
        CollectionMixedFeedsProxy.new(collection).get_models(Feed)
      },
      :mixed_feed_ids=>Proc.new{|collection|
        CollectionMixedFeedsProxy.new(collection).xxxs_ids
      }
    }
  end
end
