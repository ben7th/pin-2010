class UserIncomingToPersonalInboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_incoming_to_personal_inbox_feeds"
  end

  def xxxs_ids_db
    @user.incoming_to_personal_in_feeds_db(100).map{|feed|feed.id}
  end

  def self.add_to_cache(feed)
    creator = feed.creator
    return if creator.blank?

    feed.sent_users.each do |user|
      next if user.followings.include?(creator)

      proxy = UserIncomingToPersonalInboxFeedProxy.new(user)
      ids = proxy.xxxs_ids
      unless ids.include?(feed.id)
        ids.unshift(feed.id)
        ids.uniq!
        ids = ids[0..99] if ids.length > 100
        proxy.send(:xxxs_ids_rediscache_save,ids)
      end
    end
  end

  def self.remove_from_cache(feed)
    return if feed.creator.blank?

    feed.sent_users.each do |user|
      proxy = UserIncomingToPersonalInboxFeedProxy.new(user)
      proxy.remove_form_cache(feed.id)
    end
  end

  def self.syn_cache_when_create_contact(contact)
    fu = contact.follow_user
    u = contact.user
    feed_ids = follow_user_to_user_feed_ids(fu,u)

    proxy = UserIncomingToPersonalInboxFeedProxy.new(u)
    ids = proxy.xxxs_ids
    new_ids = ids - feed_ids
    # 排序，大的就是新的，排在前面
    new_ids = new_ids.sort{|x,y| y<=>x}.uniq
    new_ids = new_ids[0..99] if new_ids.length > 100
    proxy.send(:xxxs_ids_rediscache_save,new_ids)
  end

  def self.syn_cache_when_destroy_contact(contact)
    fu = contact.follow_user
    u = contact.user
    feed_ids = follow_user_to_user_feed_ids(fu,u)

    proxy = UserIncomingToPersonalInboxFeedProxy.new(u)
    ids = proxy.xxxs_ids
    new_ids = ids + feed_ids
    # 排序，大的就是新的，排在前面
    new_ids = new_ids.sort{|x,y| y<=>x}.uniq
    new_ids = new_ids[0..99] if new_ids.length > 100
    proxy.send(:xxxs_ids_rediscache_save,new_ids)
  end

  def self.rules
    [
      {
        :class => Feed ,
        :after_create => Proc.new {|feed|
          UserIncomingToPersonalInboxFeedProxy.add_to_cache(feed)
        },
        :after_update => Proc.new {|feed|
          if feed.to_hide?
            UserIncomingToPersonalInboxFeedProxy.remove_from_cache(feed)
          elsif feed.to_show?
            UserIncomingToPersonalInboxFeedProxy.add_to_cache(feed)
          end
        },
        :after_destroy => Proc.new {|feed|
          UserIncomingToPersonalInboxFeedProxy.remove_from_cache(feed)
        }
      },
      {
        :class => Contact,
        :after_create => Proc.new {|contact|
          UserIncomingToPersonalInboxFeedProxy.syn_cache_when_create_contact(contact)
        },
        :after_destroy => Proc.new {|contact|
          UserIncomingToPersonalInboxFeedProxy.syn_cache_when_destroy_contact(contact)
        }
      }
    ]

  end

  def self.funcs
    {
      :class  => User ,
      :incoming_to_personal_in_feeds => Proc.new {|user|
        UserIncomingToPersonalInboxFeedProxy.new(user).get_models(Feed)
      }
    }
  end

  private
  def self.follow_user_to_user_feed_ids(follow_user,user)
    Feed.find(:all,
      :conditions=>"feeds.creator_id = #{follow_user.id} and send_scopes.scope_type = 'User' and send_scopes.scope_id = #{user.id}",
      :joins=>"inner join send_scopes on feeds.id = send_scopes.feed_id",
      :order=>"feeds.id desc"
    ).map{|f|f.id}
  end
end
