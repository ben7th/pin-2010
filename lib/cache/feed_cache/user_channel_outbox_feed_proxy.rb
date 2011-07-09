class UserChannelOutboxFeedProxy < RedisBaseProxy
  def initialize(channel)
    @channel = channel
    @key = "user_channel_#{@channel.id}_outbox_feeds"
  end

  def xxxs_ids_db
    @channel.out_feeds_db.find(:all,:limit=>100,:order=>'id desc').map{|x| x.id}
  end

  def self.add_feed_cache(feed)
    channels = feed.channels_db
    channels.each do |channel|
      UserChannelOutboxFeedProxy.new(channel).add_to_cache(feed.id)
    end
  end

  def self.remove_feed_cache(feed)
    channels = feed.channels_db
    channels.each do |channel|
      UserChannelOutboxFeedProxy.new(channel).remove_from_cache(feed.id)
    end
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        UserChannelOutboxFeedProxy.add_feed_cache(feed)
      },
      :after_update => Proc.new {|feed|
        if feed.to_hide?
          UserChannelOutboxFeedProxy.remove_feed_cache(feed)
        elsif feed.to_show?
          UserChannelOutboxFeedProxy.add_feed_cache(feed)
        end
      },
      :after_destroy => Proc.new {|feed|
        UserChannelOutboxFeedProxy.remove_feed_cache(feed)
      }
    }
  end
  
  def self.funcs
    {
      :class  => Channel ,
      :out_feeds => Proc.new {|channel|
        UserChannelOutboxFeedProxy.new(channel).get_models(Feed)
      }
    }
  end
end
