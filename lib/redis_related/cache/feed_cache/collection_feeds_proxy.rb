class CollectionFeedsProxy < RedisBaseProxy
  def initialize(collection)
    @collection = collection
    @key = "collection_#{collection.id}_feeds"
  end

  def xxxs_ids_db
    @collection.feeds_db.map{|x|x.id}
  end

  def self.rules
    {
      :class => FeedCollection ,
      :after_create => Proc.new {|feed_collection|
        coll = feed_collection.collection
        feed = feed_collection.feed
        CollectionFeedsProxy.new(coll).add_to_cache(feed.id)
      },
      :after_destroy => Proc.new {|feed_collection|
        coll = feed_collection.collection
        feed = feed_collection.feed
        CollectionFeedsProxy.new(coll).remove_from_cache(feed.id)
      }
    }
  end

  def self.funcs
    {
      :class=>Collection,
      :feeds=>Proc.new{|collection|
        CollectionFeedsProxy.new(collection).get_models(Feed)
      },
      :feed_ids=>Proc.new{|collection|
        CollectionFeedsProxy.new(collection).xxxs_ids
      }
    }
  end
end
