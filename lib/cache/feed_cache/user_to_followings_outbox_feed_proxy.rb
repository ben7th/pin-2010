class UserToFollowingsOutboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_to_followings_outbox_feeds"
  end

  def xxxs_ids_db
    @user.to_followings_out_feeds_db(100).map{|f|f.id}
  end

  def self.remove_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?
    UserToFollowingsOutboxFeedProxy.new(creator).remove_from_cache(feed.id)
  end

  def self.add_feed_cache(feed)
    return unless feed.sent_all_followings?
    
    creator = feed.creator
    return if creator.blank?

    proxy = UserToFollowingsOutboxFeedProxy.new(creator)
    ids = proxy.xxxs_ids
    unless ids.include?(feed.id)
      ids.unshift(feed.id)
      ids.uniq!
      ids = ids[0..99] if ids.length > 100
      proxy.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        UserToFollowingsOutboxFeedProxy.add_feed_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserToFollowingsOutboxFeedProxy.remove_feed_cache(feed)
        elsif feed.to_show?
          UserToFollowingsOutboxFeedProxy.add_feed_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserToFollowingsOutboxFeedProxy.remove_feed_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :to_followings_out_feeds => Proc.new {|user|
        UserToFollowingsOutboxFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end
