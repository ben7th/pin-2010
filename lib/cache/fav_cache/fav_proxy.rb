module FavProxy
  module FavMethods
    def self.included(base)
      base.after_create :change_fav_cache_on_create
      base.after_destroy :change_fav_cache_on_destroy
    end

    def change_fav_cache_on_create
      FeedFavUsersProxy.new(self.feed).add_to_cache(self.user_id)
      UserFavFeedsProxy.new(self.user).add_to_cache(self.feed_id)
    end

    def change_fav_cache_on_destroy
      FeedFavUsersProxy.new(self.feed).remove_from_cache(self.user_id)
      UserFavFeedsProxy.new(self.user).remove_from_cache(self.feed_id)
    end
  end

  module UserMethods
    def fav_feeds
      UserFavFeedsProxy.new(self).xxxs_ids.map{|id|Feed.find_by_id(id)}
    end
  end

  module FeedMethods
    def fav_users
      FeedFavUsersProxy.new(self).xxxs_ids.map{|id|User.find_by_id(id)}
    end
  end
end
