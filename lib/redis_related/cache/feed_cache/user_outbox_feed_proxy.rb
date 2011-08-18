class UserOutboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_outbox_feeds"
  end

  def xxxs_ids_db
    @user.out_feeds_db(100).map{|x| x.id}
  end

  def self.remove_feed_cache(feed)
    creator = feed.creator
    return if creator.blank?
    UserOutboxFeedProxy.new(creator).remove_from_cache(feed.id)
  end

  def self.add_feed_cache(feed)
    return unless feed.public?

    uofp = UserOutboxFeedProxy.new(feed.creator)
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
        UserOutboxFeedProxy.add_feed_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserOutboxFeedProxy.remove_feed_cache(feed)
        elsif feed.to_show?
          UserOutboxFeedProxy.add_feed_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserOutboxFeedProxy.remove_feed_cache(feed)
      }
    }
  end

  def self.funcs
    {
      :class  => User ,
      :out_feeds => Proc.new {|user|
        UserOutboxFeedProxy.new(user).get_models(Feed)
      },
      :out_newest_feed => Proc.new{|user|
        feed_id = UserOutboxFeedProxy.new(user).xxxs_ids.first
        Feed.find_by_id(feed_id) if !feed_id.nil?
      },
      :out_feeds_limit => Proc.new {|user,count|
        ids = UserOutboxFeedProxy.new(user).xxxs_ids[0...count.to_i]
        ids.map{|id|Feed.find_by_id(id)}.compact
      },
      :out_feeds_more => Proc.new {|user,current_id,count|
        ids = UserOutboxFeedProxy.new(user).xxxs_ids
        ids = ids.select{|id|id.to_i < current_id.to_i}[0...count.to_i]
        ids.map{|id|Feed.find_by_id(id)}.compact
      }
    }
  end
end
