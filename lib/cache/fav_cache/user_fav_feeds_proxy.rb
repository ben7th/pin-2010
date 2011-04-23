# 用户收藏了哪些Feed的向量缓存
class UserFavFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_fav_feeds"
  end

  def xxxs_ids_db
    @user.fav_feeds_db.map{|feed|feed.id}
  end

  def self.rules
    {
      :class => Fav ,
      :after_create => Proc.new {|fav|
        UserFavFeedsProxy.new(fav.user).add_to_cache(fav.feed_id)
      },
      :after_destroy => Proc.new {|fav|
        UserFavFeedsProxy.new(fav.user).remove_from_cache(fav.feed_id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :fav_feeds => Proc.new {|user|
        UserFavFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end
