class SendScope < UserAuthAbstract
  class UnSpecifiedError < StandardError;end
  class FormatError < StandardError;end

  belongs_to :feed
  belongs_to :scope, :polymorphic => true

#  ALL_PUBLIC = "all-public"
#  ALL_FOLLOWINGS = "all-followings"
#  PRIVATE = "private"
  FOLLOWINGS = "followings"


  validates_presence_of :param

  def self.set_send_scope_by_string(feed,sendto)
    params_arr = sendto.strip.split(",").uniq
    # 默认设置为公开
    if params_arr.count == 0
      feed.send_status = Feed::SendStatus::PUBLIC
      return
    end

    # 设置 status
    statuses = params_arr.select{|param|Feed::SEND_STATUSES.include?(param)}
    raise SendScope::FormatError,"发送范围 参数格式错误" if statuses.count > 1
    status = statuses.first
    feed.send_status = (status || Feed::SendStatus::SCOPED)
    params_arr.delete status

    case feed.send_status
    when Feed::SendStatus::PRIVATE
      raise SendScope::FormatError,"发送范围 参数格式错误" if params_arr.count != 0
    when Feed::SendStatus::SCOPED
      raise SendScope::UnSpecifiedError,"必须指定发送范围" if params_arr.blank?
    end

    channel_arr = params_arr.select{|param|!!(param =~ /ch-(\d+)/)}
    followings_arr = params_arr.select{|param|param == SendScope::FOLLOWINGS}
    raise SendScope::FormatError,"发送范围 参数格式错误" if channel_arr.count > 0 && followings_arr.count > 0

    # 设置 send_scopes
    list = []
    params_arr.each do |param|
      case param
      when /ch-(\d+)/
        id = param.gsub("ch-","").to_i
        channel = Channel.find_by_id(id)
        next if channel.blank?
        list << self.new(:param=>param,:scope=>channel)
      when /u-(\d+)/
        id = param.gsub("u-","").to_i
        user = User.find_by_id(id)
        next if user.blank?
        list << self.new(:param=>param,:scope_id=>user.id,:scope_type=>user.class.to_s)
      when SendScope::FOLLOWINGS
        list << self.new(:param=>SendScope::FOLLOWINGS)
      else
        raise SendScope::FormatError,"发送范围 参数格式错误"
      end
    end
    feed.send_scopes = list
  end

  module FeedMethods
    def self.included(base)
      base.has_many :send_scopes
    end

    def sent_channels
      channels = []
      self.send_scopes.each do |ss|
        channels << ss.scope if ss.scope.is_a?(Channel)
      end
      channels
    end

    def sent_users
      users = []
      self.send_scopes.each do |ss|
        users << ss.scope if ss.scope.is_a?(User)
      end
      users
    end
    
    def sent_scope_users
      users = []
      self.send_scopes.each do |ss|
        case ss.scope
        when User
          users << ss.scope
        when Channel
          users += ss.scope.include_users_and_creator
        else
          users += self.creator.followings if ss.param == SendScope::FOLLOWINGS
        end
      end
      users.uniq
    end

  end

  module UserMethods
    def all_to_personal_in_feeds_db(limited_count = nil)
      conditions=%`
        send_scopes.scope_type = 'User'
          and send_scopes.scope_id = #{self.id}
          and feeds.hidden is not true
      `
      joins=%`
        inner join send_scopes on send_scopes.feed_id = feeds.id
      `
      find_hash = {
        :conditions=>conditions,:joins=>joins,
        :order=>"feeds.id desc"
      }
      find_hash[:limit]=limited_count unless limited_count.nil?
      Feed.find(:all,find_hash)
    end

    def to_personal_in_feeds_db(limited_count = nil)
      feeds = self.all_to_personal_in_feeds_db(limited_count)
      users = self.followings
      feeds.select do |feed|
        users.include?(feed.creator)
      end
    end

    def incoming_to_personal_in_feeds_db(limited_count = nil)
      feeds = self.all_to_personal_in_feeds_db(limited_count)
      users = self.followings
      feeds.select do |feed|
        !users.include?(feed.creator)
      end
    end
  end

  module ChannelMethods
    def self.included(base)
      base.has_many :send_scopes, :as =>:scope
      base.has_many :out_feeds_db,:through=>:send_scopes,:source=>:feed,
        :conditions=>"feeds.hidden is not true",
        :order=>"feeds.id desc"
    end
  end
end
