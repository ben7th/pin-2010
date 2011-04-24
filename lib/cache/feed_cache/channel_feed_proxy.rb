class ChannelFeedProxy < RedisBaseProxy
  def initialize(channel)
    @channel = channel
    @key = "channel_#{@channel.id}_feeds"
  end

  def xxxs_ids_db
    ids = @channel.feeds_db.map{|feed|feed.id}
    ids.sort{|x,y| y<=>x}
  end

  def self.rules
    {
      :class => Feed ,
      :after_create => Proc.new {|feed|
        channels = feed.channels_db
        channels.each do |channel|
          ChannelFeedProxy.new(channel).add_to_cache(feed.id)
        end
      },
      :after_destroy => Proc.new {|feed|
        channels = feed.channels_db
        channels.each do |channel|
          ChannelFeedProxy.new(channel).remove_from_cache(feed.id)
        end
      }
    }
  end
  
  def self.funcs
    {
      :class  => Channel ,
      :feeds => Proc.new {|channel|
        ChannelFeedProxy.new(channel).get_models(Feed)
      },
      :last_feed => Proc.new{|channel|
        id = ChannelFeedProxy.new(channel).xxxs_ids.first
        Feed.find_by_id id
      },
      :newest_feed => Proc.new{|channel|
        channel.last_feed
      }
    }
  end
end