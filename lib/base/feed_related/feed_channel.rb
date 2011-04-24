class FeedChannel < UserAuthAbstract
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
        :conditions=>{:creator_id=>self.id},
        :joins=>"inner join feed_channels on feed_channels.feed_id = feeds.id"
      )
    end

    # user(self) 发送的 没有指定channel的 feeds
    def send_feeds_of_no_channel_db
      feeds = self.out_feeds_db
      feeds - send_feeds_of_channels_db
    end

    def inbox_feeds_of_no_channel_db
      feed_list = self.followings_and_self.map do |user|
        # 一个人发送的 没有指定频道的 feed
        user.send_feeds_of_no_channel_db
      end.flatten
      feed_list.sort{|x,y|y.id <=> x.id }
    end
  end

  module ChannelMethods
    def self.included(base)
      base.has_many :feed_channels,:dependent=>:destroy,:order=>"id desc"
      base.has_many :feeds_db,:through=>:feed_channels,:source=>:feed,:order=>"feed_channels.id desc"
    end
  end

end