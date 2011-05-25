class UserInboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_inbox_feeds"
  end

  def xxxs_ids_db
    id_list_from_followings_and_self_newer_than(nil)
  end

  def id_list_from_followings_and_self_newer_than(newest_id)
    _id_list = @user.followings_and_self.map{|user|
      UserOutboxFeedProxy.new(user).xxxs_ids
    }.flatten
    # 排序，大的就是新的，排在前面
    ids = _id_list.sort{|x,y| y<=>x}

    if !newest_id.nil?
      ids = ids.compact.select{|x| x > newest_id}
    end
    
    ids[0..199]
  end

  def xxxs_ids
    xxxs_ids_db
  end

  def self.add_feed_cache(feed)
    feed_creator = feed.creator
    users = feed_creator.hotfans + [feed_creator]
    users.each do |user|
      UserInboxFeedProxy.new(user).add_to_cache(feed.id)
    end
  end

  def self.remove_feed_cache(feed)
    feed_creator = feed.creator
    return if feed_creator.blank?
    users = feed_creator.hotfans + [feed_creator]
    users.each do |user|
      UserInboxFeedProxy.new(user).remove_from_cache(feed.id)
    end
  end

  def self.rules
    [
      {
        :class => Feed ,
        :after_create => Proc.new {|feed|
          UserInboxFeedProxy.add_feed_cache(feed)
        },
        :after_update => Proc.new {|feed|
          if feed.to_hide?
            UserInboxFeedProxy.remove_feed_cache(feed)
          elsif feed.to_show?
            UserInboxFeedProxy.add_feed_cache(feed)
          end
        },
        :after_destroy => Proc.new {|feed|
          UserInboxFeedProxy.remove_feed_cache(feed)
        }
      },
      {
        :class => Contact,
        :after_create => Proc.new{|contact|
          # add_user_outbox_to_self_inbox
          uifp = UserInboxFeedProxy.new(contact.user)
          self_inbox_ids = uifp.xxxs_ids
          user_outbox_ids = UserOutboxFeedProxy.new(contact.follow_user).xxxs_ids

          ids = (user_outbox_ids + self_inbox_ids).uniq.sort{|x,y| y<=>x}

          uifp.send(:xxxs_ids_rediscache_save,ids[0..199])
        },
        :after_destroy => Proc.new{|contact|
          # remove_user_outbox_from_self_inbox
          uifp = UserInboxFeedProxy.new(contact.user)
          self_inbox_ids = uifp.xxxs_ids
          fuser = contact.follow_user
          user_outbox_ids = UserOutboxFeedProxy.new(fuser).xxxs_ids

          ids = self_inbox_ids - user_outbox_ids
          ids = ids.select do |feed_id|
            feed = Feed.find_by_id(feed_id)
            feed && feed.creator != fuser
          end
          
          uifp.send(:xxxs_ids_rediscache_save,ids[0..199])
        }
      }
    ]

  end

  def self.funcs
    {
      :class  => User ,
      :in_feeds => Proc.new {|user|
        UserInboxFeedProxy.new(user).get_models(Feed)
      },
      :in_feeds_more => Proc.new {|user,count,vector|
        UserInboxFeedProxy.new(user).vector_more(count,Feed,vector)
      }
    }
  end
end