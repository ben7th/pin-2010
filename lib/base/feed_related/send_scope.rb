class SendScope < UserAuthAbstract
  class UnSpecifiedError < StandardError;end
  class FormatError < StandardError;end

  belongs_to :feed
  belongs_to :scope, :polymorphic => true

  ALL_PUBLIC = "all-public"
  ALL_FOLLOWINGS = "all-followings"


  validates_presence_of :param

  def self.build_list_form_string(params_string)
    params_arr = params_string.split(",")
    list = []
    arr = params_arr.select do |param|
      param == ALL_PUBLIC ||
        param == ALL_FOLLOWINGS ||
        !!(param =~ /ch-(\d+)/)
    end
    raise SendScope::FormatError,"发送范围 参数格式错误" if arr.count > 1

    params_arr.each do |param|
      case param
      when ALL_PUBLIC
        list << self.new(:param=>ALL_PUBLIC)
      when ALL_FOLLOWINGS
        list << self.new(:param=>ALL_FOLLOWINGS)
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
      else
        raise SendScope::FormatError,"发送范围 参数格式错误"
      end
    end
    raise SendScope::UnSpecifiedError,"必须制定发送范围" if list.blank?
    list
  end

  module FeedMethods
    def self.included(base)
      base.has_many :send_scopes
    end

    def public?
      scopes = self.send_scopes.select{|ss|ss.param == SendScope::ALL_PUBLIC}
      scopes.count != 0
    end

    def sent_all_followings?
      scopes = self.send_scopes.select{|ss|ss.param == SendScope::ALL_FOLLOWINGS}
      scopes.count != 0
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
