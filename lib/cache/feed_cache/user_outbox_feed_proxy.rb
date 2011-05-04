class UserOutboxFeedProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_outbox_feeds"
  end

  def xxxs_ids_db
    @user.out_feeds_db.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        uofp = UserOutboxFeedProxy.new(feed.creator)
        ids = uofp.xxxs_ids
        ids.unshift(feed.id)
        ids = ids[0..99] if ids.length > 100
        uofp.send(:xxxs_ids_rediscache_save,ids)
      },
      :after_destroy => Proc.new {|feed|
        creator = feed.creator
        next if creator.blank?
        UserOutboxFeedProxy.new(creator).remove_from_cache(feed.id)
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
      }
    }
  end
end
