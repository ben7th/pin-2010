class CollectionWithPhotoFeedsProxy < RedisBaseProxy
  def initialize(collection)
    @collection = collection
    @key = "collection_#{collection.id}_with_photo_feeds"
  end

  def xxxs_ids_db
    @collection.with_photo_feeds_db.map{|x|x.id}
  end

  def self.add_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    return if feed.main_post.post_photos.blank?
    proxy = CollectionWithPhotoFeedsProxy.new(coll)
    ids = proxy.xxxs_ids
    unless ids.include?(feed.id)
      ids = ids.unshift(feed.id).uniq
      ids = ids.sort{|id1,id2|id2<=>id1}
      proxy.send(:send,:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.remove_feed_cache(feed_collection)
    coll = feed_collection.collection
    feed = feed_collection.feed
    CollectionWithPhotoFeedsProxy.new(coll).remove_from_cache(feed.id)
  end

  def self.rules
    {
      :class => FeedCollection ,
      :after_create => Proc.new {|feed_collection|
        CollectionWithPhotoFeedsProxy.add_feed_cache(feed_collection)
      },
      :after_destroy => Proc.new {|feed_collection|
        CollectionWithPhotoFeedsProxy.remove_feed_cache(feed_collection)
      }
    }
  end

  def self.funcs
    {
      :class=>Collection,
      :with_photo_feeds=>Proc.new{|collection|
        CollectionWithPhotoFeedsProxy.new(collection).get_models(Feed)
      },
      :with_photo_feed_ids=>Proc.new{|collection|
        CollectionWithPhotoFeedsProxy.new(collection).xxxs_ids
      }
    }
  end
end
