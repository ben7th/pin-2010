module NoCollectionFeedsCacheModule

  # 所有feed
  class FeedsProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{user.id}_no_collection_feeds"
    end

    def xxxs_ids_db
      @user.no_collection_feeds_db.map{|x|x.id}
    end
  end

  # 带有正文text的feed
  class FeedsWithTextProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{user.id}_no_collection_with_text_feeds"
    end

    def xxxs_ids_db
      @user.no_collection_with_text_feeds_db.map{|x|x.id}
    end
  end

  # 带有照片photo的feed
  class FeedsWithPhotoProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{user.id}_no_collection_with_photo_feeds"
    end

    def xxxs_ids_db
      @user.no_collection_with_photo_feeds_db.map{|x|x.id}
    end
  end

  # 同时带有正文和照片的feed
  class FeedsMixedProxy < RedisBaseProxy
    def initialize(user)
      @user = user
      @key = "user_#{user.id}_no_collection_mixed_feeds"
    end

    def xxxs_ids_db
      @user.no_collection_mixed_feeds_db.map{|x|x.id}
    end
  end

  class LogicRules
    
    def self.add_to_cache(user, feed)
      feed_id = feed.id
      
               FeedsProxy.new(user).add_to_cache_and_sort(feed_id)
       FeedsWithTextProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.detail.blank?
      FeedsWithPhotoProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.photos.blank?
          FeedsMixedProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.detail.blank? && !feed.photos.blank?
    end

    def self.remove_from_cache(user, feed)
      feed_id = feed.id

               FeedsProxy.new(user).remove_from_cache(feed_id)
       FeedsWithTextProxy.new(user).remove_from_cache(feed_id)
      FeedsWithPhotoProxy.new(user).remove_from_cache(feed_id)
          FeedsMixedProxy.new(user).remove_from_cache(feed_id)
    end

    def self.rules
      [
        {
          :class => FeedCollection,
          :after_destroy => Proc.new{|feed_collection|
            feed = feed_collection.feed
            collection = feed_collection.collection
            if (feed.collections-[collection]).blank?
              user = feed.creator
              self.remove_from_cache(user, feed)
              self.add_to_cache(user, feed)
            end
          }
        },
        {
          :class => Feed,
          :after_save => Proc.new {|feed|
            user = feed.creator
            self.remove_from_cache(user, feed)
            if feed.collections.blank?
              self.add_to_cache(user, feed)
            end
          },
          :after_destroy => Proc.new {|feed|
            user = feed.creator
            self.remove_from_cache(user, feed)
          }
        }
      ]
    end

    def self.funcs
      {
        :class=>User,

        :no_collection_feeds    => Proc.new{|user| FeedsProxy.new(user).get_models(Feed) },
        :no_collection_feed_ids => Proc.new{|user| FeedsProxy.new(user).xxxs_ids },

        :no_collection_with_text_feeds    => Proc.new{|user| FeedsWithTextProxy.new(user).get_models(Feed) },
        :no_collection_with_text_feed_ids => Proc.new{|user| FeedsWithTextProxy.new(user).xxxs_ids },

        :no_collection_with_photo_feeds    => Proc.new{|user| FeedsWithPhotoProxy.new(user).get_models(Feed) },
        :no_collection_with_photo_feed_ids => Proc.new{|user| FeedsWithPhotoProxy.new(user).xxxs_ids },

        :no_collection_mixed_feeds    => Proc.new{|user| FeedsMixedProxy.new(user).get_models(Feed) },
        :no_collection_mixed_feed_ids => Proc.new{|user| FeedsMixedProxy.new(user).xxxs_ids }

      }
    end
    
  end

end
