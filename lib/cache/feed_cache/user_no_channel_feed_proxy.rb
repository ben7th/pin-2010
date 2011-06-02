class UserNoChannelFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_no_channel_feeds"
  end

  def xxxs_ids_db
    @user.inbox_feeds_of_no_channel_db.map{|feed|feed.id}
  end

  def self.add_feed_cache(feed)
    return if !feed.channels_db.blank?
    users = feed.creator.hotfans + [feed.creator]
    users.each do |user|
      UserNoChannelFeedProxy.new(user).add_to_cache(feed.id)
    end
  end

  def self.remove_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?
    return if !feed.channels_db.blank?
    users = creator.hotfans + [feed.creator]
    users.each do |user|
      UserNoChannelFeedProxy.new(user).remove_from_cache(feed.id)
    end
  end

  def self.rules
    [
      {
        :class => Feed ,
        :after_create => Proc.new {|feed|
          UserNoChannelFeedProxy.add_feed_cache(feed)
        },
        :after_update => Proc.new {|feed|
          if feed.to_hide?
            UserNoChannelFeedProxy.remove_feed_cache(feed)
          elsif feed.to_show?
            UserNoChannelFeedProxy.add_feed_cache(feed)
          end
        },
        :after_destroy => Proc.new {|feed|
          UserNoChannelFeedProxy.remove_feed_cache(feed)
        }
      },
      {
        :class => Contact,
        :after_create => Proc.new {|contact|
          #add_user_feeds_of_no_channel_to_self_no_channel
          uncfp = UserNoChannelFeedProxy.new(contact.user)
          self_ids = uncfp.xxxs_ids
          user_ids = UserNoChannelFeedProxy.new(contact.follow_user).xxxs_ids
          ids = (self_ids + user_ids).sort{|x,y|y<=>x}
          ids.uniq!
          uncfp.send(:xxxs_ids_rediscache_save,ids)
        },
        :after_destroy => Proc.new {|contact|
          #remove_user_feeds_of_no_channel_from_self_no_channel
          uncfp = UserNoChannelFeedProxy.new(contact.user)
          self_ids = uncfp.xxxs_ids
          fuser = contact.follow_user
          user_ids = UserNoChannelFeedProxy.new(fuser).xxxs_ids

          ids = self_ids - user_ids
          ids = ids.select do |feed_id|
            feed = Feed.find_by_id(feed_id)
            feed && feed.creator != fuser
          end

          uncfp.send(:xxxs_ids_rediscache_save,ids)
        }
      }
    ]
  end

  def self.funcs
    {
      :class  => User ,
      :inbox_feeds_of_no_channel => Proc.new {|user|
        UserNoChannelFeedProxy.new(user).get_models(Feed)
      }
    }
  end
end
