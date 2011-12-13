module CollectionFeedsCacheModule

  # 所有feed
  class FeedsProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "collection_#{collection.id}_feeds"
    end

    def xxxs_ids_db
      @collection.feeds_db.map{|x|x.id}
    end

    def self.tidy!
      self.base_tidy!(Collection,Feed)
    end
  end

  # 带有正文text的feed
  class FeedsWithTextProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "collection_#{collection.id}_with_text_feeds"
    end

    def xxxs_ids_db
      @collection.with_text_feeds_db.map{|x|x.id}
    end

    def self.tidy!
      self.base_tidy!(Collection,Feed)
    end
  end

  # 带有照片photo的feed
  class FeedsWithPhotoProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "collection_#{collection.id}_with_photo_feeds"
    end

    def xxxs_ids_db
      @collection.with_photo_feeds_db.map{|x|x.id}
    end

    def self.tidy!
      self.base_tidy!(Collection,Feed)
    end
  end

  # 同时带有正文和照片的feed
  class FeedsMixedProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "collection_#{collection.id}_mixed_feeds"
    end

    def xxxs_ids_db
      @collection.mixed_feeds_db.map{|x|x.id}
    end
    
    def self.tidy!
      self.base_tidy!(Collection,Feed)
    end
  end

  class LogicRules
    
    def self.add_to_cache(collection, feed)
      feed_id = feed.id
      
               FeedsProxy.new(collection).add_to_cache_and_sort(feed_id)
       FeedsWithTextProxy.new(collection).add_to_cache_and_sort(feed_id) if !feed.detail.blank?
      FeedsWithPhotoProxy.new(collection).add_to_cache_and_sort(feed_id) if !feed.photos.blank?
          FeedsMixedProxy.new(collection).add_to_cache_and_sort(feed_id) if !feed.detail.blank? && !feed.photos.blank?
    end

    def self.remove_from_cache(collection, feed)
      feed_id = feed.id

               FeedsProxy.new(collection).remove_from_cache(feed_id)
       FeedsWithTextProxy.new(collection).remove_from_cache(feed_id)
      FeedsWithPhotoProxy.new(collection).remove_from_cache(feed_id)
          FeedsMixedProxy.new(collection).remove_from_cache(feed_id)
    end

    def self.rules
      [
        {
          :class => FeedCollection ,
          :after_create => Proc.new {|fc| # feed_collection
            self.add_to_cache(fc.collection, fc.feed)
          },
          :after_destroy => Proc.new {|fc| # feed_collection
            self.remove_from_cache(fc.collection, fc.feed)
          }
        },
        
        {
          :class => Feed,
          :after_update => Proc.new {|feed|
            feed.collections.each do |collection|
              self.remove_from_cache(collection, feed)
              self.add_to_cache(collection, feed)
            end
          }
        }
      ]
    end

    def self.funcs
      {
        :class=>Collection,

        :feeds    => Proc.new{|collection| FeedsProxy.new(collection).get_models(Feed) },
        :feed_ids => Proc.new{|collection| FeedsProxy.new(collection).xxxs_ids },

        :with_text_feeds    => Proc.new{|collection| FeedsWithTextProxy.new(collection).get_models(Feed) },
        :with_text_feed_ids => Proc.new{|collection| FeedsWithTextProxy.new(collection).xxxs_ids },

        :with_photo_feeds    => Proc.new{|collection| FeedsWithPhotoProxy.new(collection).get_models(Feed) },
        :with_photo_feed_ids => Proc.new{|collection| FeedsWithPhotoProxy.new(collection).xxxs_ids },

        :mixed_feeds    => Proc.new{|collection| FeedsMixedProxy.new(collection).get_models(Feed) },
        :mixed_feed_ids => Proc.new{|collection| FeedsMixedProxy.new(collection).xxxs_ids }

      }
    end
    
  end

end
