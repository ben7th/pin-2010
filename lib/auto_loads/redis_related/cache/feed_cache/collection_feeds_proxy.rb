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
        proxy = CollectionFeedsProxy.new(coll)
        ids = proxy.xxxs_ids
        unless ids.include?(feed.id)
          ids = ids.unshift(feed.id).uniq
          ids = ids.sort{|id1,id2|id2<=>id1}
          proxy.send(:send,:xxxs_ids_rediscache_save,ids)
        end
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

  def self.tidy!
    self.base_tidy!(Collection,Feed)
  end
end
