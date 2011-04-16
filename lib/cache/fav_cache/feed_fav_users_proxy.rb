# Feed被哪些用户收藏的向量缓存
class FeedFavUsersProxy < RedisBaseProxy
  def initialize(feed)
    @feed = feed
    @key = "feed_#{feed.id}_fav_users"
  end

  def xxxs_ids_db
    @feed.fav_users_db.map{|user|user.id}
  end

  def self.rules
    {
      :class => Fav ,
      :after_create => Proc.new {|fav|
        FeedFavUsersProxy.new(fav.feed).add_to_cache(fav.user_id)
      },
      :after_destroy => Proc.new {|fav|
        FeedFavUsersProxy.new(fav.feed).remove_from_cache(fav.user_id)
      }
    }
  end

  def self.funcs
    {
      :class => Feed ,
      :fav_users => Proc.new {|feed|
        ids = FeedFavUsersProxy.new(feed).xxxs_ids
        User.find_all_by_id ids
      }
    }
  end
end
