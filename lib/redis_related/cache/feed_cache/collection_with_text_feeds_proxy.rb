class CollectionWithTextFeedsProxy < RedisBaseProxy
  def initialize(collection)
    @collection = collection
    @key = "collection_#{collection.id}_with_text_feeds"
  end

  def xxxs_ids_db
    @collection.with_text_feeds_db.map{|x|x.id}
  end

  def self.add_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    return if feed.main_post.detail.blank?
    CollectionWithTextFeedsProxy.new(coll).add_to_cache(feed.id)
  end

  def self.remove_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    CollectionWithTextFeedsProxy.new(coll).remove_from_cache(feed.id)
  end

  def self.rules
    {
      :class => FeedCollection ,
      :after_create => Proc.new {|feed_collection|
        CollectionWithTextFeedsProxy.add_feed_cache(feed_collection)
      },
      :after_destroy => Proc.new {|feed_collection|
        CollectionWithTextFeedsProxy.remove_feed_cache(feed_collection)
      }
    }
  end

  def self.funcs
    {
      :class=>Collection,
      :with_text_feeds=>Proc.new{|collection|
        CollectionWithTextFeedsProxy.new(collection).get_models(Feed)
      },
      :with_text_feed_ids=>Proc.new{|collection|
        CollectionWithTextFeedsProxy.new(collection).xxxs_ids
      }
    }
  end
end
