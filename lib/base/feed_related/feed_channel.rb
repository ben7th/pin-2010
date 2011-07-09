class FeedChannel < UserAuthAbstract
  belongs_to :feed
  belongs_to :channel
  
  validates_presence_of :feed
  validates_presence_of :channel
  validates_uniqueness_of :feed_id,:scope=>"channel_id"

  module FeedMethods
    def self.included(base)
      base.has_many :feed_channels,:dependent=>:destroy,:order=>"id desc"
      base.has_many :channels_db,:through=>:feed_channels,:source=>:channel,:order=>"feed_channels.id desc"
    end
  end

  module ChannelMethods
    def self.included(base)
      base.has_many :feed_channels,:dependent=>:destroy,:order=>"id desc"
      base.has_many :out_feeds_db,:through=>:feed_channels,:source=>:feed,
        :conditions=>"feeds.hidden is not true",
        :order=>"feeds.id desc"
    end
  end

end
