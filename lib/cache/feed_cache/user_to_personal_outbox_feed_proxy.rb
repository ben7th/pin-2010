class UserToPersonalOutboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_to_personal_outbox_feeds"
  end

  def xxxs_ids_db
    @user.to_personal_out_feeds_db(100).map{|feed|feed.id}
  end

  def self.add_to_cache(feed)
    return if feed.sent_users.blank?
    return if feed.creator.blank?

    proxy = UserToPersonalOutboxFeedProxy.new(feed.creator)
    ids = proxy.xxxs_ids
    unless ids.include?(feed.id)
      ids.unshift(feed.id)
      ids.uniq!
      ids = ids[0..99] if ids.length > 100
      proxy.send(:xxxs_ids_rediscache_save,ids)
    end
  end

  def self.remove_from_cache(feed)
    return if feed.creator.blank?
    proxy = UserToPersonalOutboxFeedProxy.new(feed.creator)
    proxy.remove_form_cache(feed.id)
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        UserToPersonalOutboxFeedProxy.add_to_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserToPersonalOutboxFeedProxy.remove_from_cache(feed)
        elsif feed.to_show?
          UserToPersonalOutboxFeedProxy.add_to_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserToPersonalOutboxFeedProxy.remove_from_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :to_personal_out_feeds => Proc.new {|user|
        UserToPersonalOutboxFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end
