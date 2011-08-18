class UserBeInvitedFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_be_invited_feeds"
  end

  def xxxs_ids_db
    @user.be_invited_feeds_db.map{|feed|feed.id}
  end

  def self.rules
    {
      :class => FeedInvite ,
      :after_create => Proc.new {|feed_invite|
        user = feed_invite.user
        feed = feed_invite.feed
        UserBeInvitedFeedsProxy.new(user).add_to_cache(feed.id)
      },
      :after_destroy => Proc.new {|feed_invite|
        user = feed_invite.user
        feed = feed_invite.feed
        next if feed.blank? || user.blank?
        UserBeInvitedFeedsProxy.new(user).remove_from_cache(feed.id)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :be_invited_feeds => Proc.new {|user|
        UserBeInvitedFeedsProxy.new(user).get_models(Feed)
      }
    }
  end
end
