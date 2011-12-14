module HomeTimelineCacheModule

  class HomeTimelineFeedsProxy < RedisBaseProxy
    
    def initialize(user)
      @user = user
      @key = "user_#{@user.id}_home_timeline_feeds"
    end

    def xxxs_ids_db
      @user.home_timeline_collections.map{|c|c.feed_ids}.flatten.uniq.sort{|id1, id2| id2<=>id1 }
    end

  end
  
  class HomeTimelineFeedsWithTextProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "user_#{@user.id}_home_timeline_with_text_feeds"
    end
    
    def xxxs_ids_db
      @user.home_timeline_collections.map{|c|c.with_text_feed_ids}.flatten.uniq.sort{|id1, id2| id2<=>id1 }
    end
  end

  class HomeTimelineFeedsWithPhotoProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "user_#{@user.id}_home_timeline_with_photo_feeds"
    end

    def xxxs_ids_db
      @user.home_timeline_collections.map{|c|c.with_photo_feed_ids}.flatten.uniq.sort{|id1, id2| id2<=>id1 }
    end
  end

  class HomeTimelineFeedsMixedProxy < RedisBaseProxy
    def initialize(collection)
      @collection = collection
      @key = "user_#{@user.id}_home_timeline_mixed_feeds"
    end

    def xxxs_ids_db
      @user.home_timeline_collections.map{|c|c.mixed_feed_ids}.flatten.uniq.sort{|id1, id2| id2<=>id1 }
    end
  end



  class LogicRules

    def self._add(user, feed)
      feed_id = feed.id

               HomeTimelineFeedsProxy.new(user).add_to_cache_and_sort(feed_id)
       HomeTimelineFeedsWithTextProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.detail.blank?
      HomeTimelineFeedsWithPhotoProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.photos.blank?
          HomeTimelineFeedsMixedProxy.new(user).add_to_cache_and_sort(feed_id) if !feed.detail.blank? && !feed.photos.blank?
    end

    def self._remove(user, feed)
      feed_id = feed.id

               HomeTimelineFeedsProxy.new(user).remove_from_cache(feed_id)
       HomeTimelineFeedsWithTextProxy.new(user).remove_from_cache(feed_id)
      HomeTimelineFeedsWithPhotoProxy.new(user).remove_from_cache(feed_id)
          HomeTimelineFeedsMixedProxy.new(user).remove_from_cache(feed_id)
    end

    # ------------

    def self.update_cache_when_feed_create(feed)
      # 更新 自己和所有fans 的 home_timeline 缓存
      feed.creator.fans_and_self.each do |user|
        self._add(user, feed) if feed.public_to?(user)
      end
    end

    def self.update_cache_when_feed_update(feed)
      # 更新 自己和所有fans 的 home_timeline 缓存
      feed.creator.fans_and_self.each do |user|
        if feed.public_to?(user)
          self._add(user, feed)
        else
          self._remove(user, feed)
        end
      end
    end

    def self.update_cache_when_feed_destroy(feed)
      # 更新 自己和所有fans 的 home_timeline 缓存
      feed.creator.fans_and_self.each do |user|
        self._remove(user, feed)
      end
    end

    def self.update_cache_when_channel_user_create(channel_user)
      user    = channel_user.user
      creator = channel_user.channel.creator
      
      user.public_collections.each { |c|
        c.feeds.each { |feed|
          self._add(creator, feed)
        }
      }
    end

    def self.update_cache_when_channel_user_destroy(channel_user)
      user    = channel_user.user
      creator = channel_user.channel.creator

      return if creator.followings?(user)

      user.public_collections.each { |c|
        c.feeds.each { |feed|
          self._remove(creator, feed)
        }
      }
    end

    def self.rules
      [
        {
          :class=>Feed,
          :after_create=>Proc.new{|feed|
            LogicRules.update_cache_when_feed_create(feed)
          },
          :after_update=>Proc.new{|feed|
            LogicRules.update_cache_when_feed_update(feed)
          },
          :after_destroy=>Proc.new{|feed|
            LogicRules.update_cache_when_feed_destroy(feed)
          }
        },
        {
          :class=>ChannelUser,
          :after_create=>Proc.new{|channel_user|
            LogicRules.update_cache_when_channel_user_create(channel_user)
          },
          :after_destroy=>Proc.new{|channel_user|
            LogicRules.update_cache_when_channel_user_destroy(channel_user)
          }
        }
      ]
    end

    def self.funcs
      {
        :class=>User,
        :home_timeline_feeds=>Proc.new{|user|
          HomeTimelineFeedsProxy.new(user).get_models(Feed)
        },
        :home_timeline_with_text_feeds=>Proc.new{|user|
          HomeTimelineFeedsWithTextProxy.new(user).get_models(Feed)
        },
        :home_timeline_with_photo_feeds=>Proc.new{|user|
          HomeTimelineFeedsWithPhotoProxy.new(user).get_models(Feed)
        },
        :home_timeline_mixed_feeds=>Proc.new{|user|
          HomeTimelineFeedsMixedProxy.new(user).get_models(Feed)
        },
        :home_timeline_feed_ids=>Proc.new{|user|
          HomeTimelineFeedsProxy.new(user).xxxs_ids
        },
        :home_timeline_with_text_feed_ids=>Proc.new{|user|
          HomeTimelineFeedsWithTextProxy.new(user).xxxs_ids
        },
        :home_timeline_with_photo_feed_ids=>Proc.new{|user|
          HomeTimelineFeedsWithPhotoProxy.new(user).xxxs_ids
        },
        :home_timeline_mixed_feed_ids=>Proc.new{|user|
          HomeTimelineFeedsMixedProxy.new(user).xxxs_ids
        }
      }
    end
  end
    
end
