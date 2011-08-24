class UserPrivateFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_private_feeds"
  end

  def xxxs_ids_db
    @user.private_feeds_db(100).map{|x| x.id}
  end

  def self.remove_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?
    UserPrivateFeedProxy.new(creator).remove_from_cache(feed.id)
  end

  def self.add_feed_cache(feed)
    return unless feed.private?

    uofp = UserPrivateFeedProxy.new(feed.creator)
    ids = uofp.xxxs_ids
    unless ids.include?(feed.id)
      ids.unshift(feed.id)
      ids.uniq!
      ids = ids[0..99] if ids.length > 100
      uofp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        UserPrivateFeedProxy.add_feed_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserPrivateFeedProxy.remove_feed_cache(feed)
        elsif feed.to_show?
          UserPrivateFeedProxy.add_feed_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserPrivateFeedProxy.remove_feed_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :private_feeds => Proc.new {|user|
        UserPrivateFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end
