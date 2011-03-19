class FeedChannel < ActiveRecord::Base
  belongs_to :feed
  belongs_to :channel

  module FeedMethods
    def self.included(base)
      base.has_many :feed_channels,:dependent=>:destroy,:order=>"id desc"
      base.has_many :channels_db,:through=>:feed_channels,:source=>:channel,:order=>"feed_channels.id desc"
    end
  end

  module UserMethods
    # user(self) 发送给 channel 的 feeds
    def send_feeds_of_channel_db(channel)
      fcs = FeedChannel.find(:all,:conditions=>{:channel_id=>channel.id})
      fcs.map{ |fc|fc.feed}.compact.uniq
    end

    # user(self) 发送的 制定了channel 的 feeds
    def send_feeds_of_channels_db
      Feed.find(:all,
        :conditions=>{:email=>self.email},
        :joins=>"inner join feed_channels on feed_channels.feed_id = feeds.id"
      )
    end

    # user(self) 发送的 没有指定channel的 feeds
    def send_feeds_of_no_channel_db
      feeds = Feed.find(:all,:conditions=>{:email=>self.email})
      feeds - send_feeds_of_channels_db
    end
  end

  module ChannelMethods
    def self.included(base)
      base.has_many :feed_channels,:dependent=>:destroy,:order=>"id desc"
      base.has_many :feeds_db,:through=>:feed_channels,:source=>:feed,:order=>"feed_channels.id desc"
    end
  end

end
