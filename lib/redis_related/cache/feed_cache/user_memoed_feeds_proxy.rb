class UserMemoedFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_memoed_feeds"
  end

  def xxxs_ids_db
    @user.memoed_feeds_db.map{|feed|feed.id}
  end

  def self.rules
    {
      :class => Post ,
      :after_create => Proc.new {|post|
        user = post.user
        feed = post.feed
        unless post.memo.nil?
          UserMemoedFeedsProxy.new(user).add_to_cache(feed.id)
        end
      },
      :after_update => Proc.new {|post|
        user = post.user
        feed = post.feed
        next if feed.blank? || user.blank?
        UserMemoedFeedsProxy.new(user).remove_from_cache(feed.id)
        unless post.memo.nil?
          UserMemoedFeedsProxy.new(user).add_to_cache(feed.id)
        end
      },
      :after_destroy => Proc.new {|post|
        user = post.user
        feed = post.feed
        next if feed.blank? || user.blank?
        UserMemoedFeedsProxy.new(user).remove_from_cache(feed.id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :memoed_feeds => Proc.new {|user|
        UserMemoedFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end
