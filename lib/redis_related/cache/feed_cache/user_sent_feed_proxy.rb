class UserSentFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_sent_feeds"
  end

  def xxxs_ids_db
    @user.sent_feeds_db.limited(100).map{|f|f.id}
  end

  def self.remove_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?
    UserSentFeedProxy.new(creator).remove_from_cache(feed.id)
  end

  def self.add_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?

    usfp = UserSentFeedProxy.new(creator)
    ids = usfp.xxxs_ids
    unless ids.include?(feed.id)
      ids.unshift(feed.id)
      ids.uniq!
      ids = ids[0..99] if ids.length > 100
      usfp.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        UserSentFeedProxy.add_feed_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserSentFeedProxy.remove_feed_cache(feed)
        elsif feed.to_show?
          UserSentFeedProxy.add_feed_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserSentFeedProxy.remove_feed_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :sent_feeds => Proc.new {|user|
        UserSentFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end
