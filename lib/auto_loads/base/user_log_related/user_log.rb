class UserLog < UserAuthAbstract
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :kind
  validates_presence_of :info_json
  
  ADD_FEED = "ADD_FEED"
  EDIT_FEED = "EDIT_FEED"
  ADD_VIEWPOINT = "ADD_VIEWPOINT"
  EDIT_VIEWPOINT = "EDIT_VIEWPOINT"
  ADD_CONTACT = "ADD_CONTACT"

  named_scope :of_user,lambda{|user|
    {
      :conditions=>"user_id = #{user.id}",
      :order=>'id desc'
    }
  }

  def self.last_of_user(user)
    UserLog.of_user(user).first
  end

  def info_hash
    ActiveSupport::JSON.decode(self.info_json)
  end

  def info
    hash = self.info_hash
    case self.kind
    when ADD_FEED
      feed = Feed.find_by_id(hash["feed_id"])
      Struct.new(:feed,:user,:kind).new(feed,self.user,self.kind)
    when EDIT_FEED
      feed = Feed.find_by_id(hash["feed_id"])
      Struct.new(:feed,:user,:kind).new(feed,self.user,self.kind)
    when ADD_VIEWPOINT
      viewpoint = Viewpoint.find_by_id(hash["viewpoint_id"])
      Struct.new(:viewpoint,:feed,:user,:kind).new(viewpoint,viewpoint.feed,self.user,self.kind)
    when EDIT_VIEWPOINT
      viewpoint = Viewpoint.find_by_id(hash["viewpoint_id"])
      Struct.new(:viewpoint,:feed,:user,:kind).new(viewpoint,viewpoint.feed,self.user,self.kind)
    when ADD_CONTACT
      contact_user = User.find_by_id(hash["contact_user_id"])
      Struct.new(:contact_user,:user,:kind).new(contact_user,self.user,self.kind)
    end
  end

  def info=(info)
    self.info_json = info.to_json
  end

  module UserMethods
    def outbox_logs_db
      UserLog.of_user(self)
    end

    def inbox_logs_db
      logs = self.followings.map do |user|
        UserLog.of_user(user)
      end.flatten
      logs.sort{|a,b|b<=>a}
    end

    def create_add_contact_user_log(contact_user)
      UserLog.create(:user=>self,:kind=>UserLog::ADD_CONTACT,:info=>{"contact_user_id"=>contact_user.id})
    end

    def create_add_feed_log(feed)
      UserLog.create(:user=>self,:kind=>UserLog::ADD_FEED,:info=>{"feed_id"=>feed.id})
    end

    def create_edit_feed_log(feed)
      UserLog.create(:user=>self,:kind=>UserLog::EDIT_FEED,:info=>{"feed_id"=>feed.id})
    end

    def create_add_viewpoint_log(viewpoint)
      UserLog.create(:user=>self,:kind=>UserLog::ADD_VIEWPOINT,:info=>{"viewpoint_id"=>viewpoint.id})
    end

    def create_edit_viewpoint_log(viewpoint)
      UserLog.create(:user=>self,:kind=>UserLog::EDIT_VIEWPOINT,:info=>{"viewpoint_id"=>viewpoint.id})
    end

    def last_add_contact_user
      ul = UserLog.find(:first,:conditions=>"kind = '#{UserLog::ADD_CONTACT}' and user_id = #{self.id}",:order=>"id desc")
      return if ul.blank?
      User.find_by_id(ul.info_hash["contact_user_id"])
    end

    def last_edit_feed
      ul = UserLog.find(:first,:conditions=>"kind = '#{UserLog::EDIT_FEED}' and user_id = #{self.id}",:order=>"id desc")
      return if ul.blank?
      Feed.find_by_id(ul.info_hash["feed_id"])
    end

    def last_edit_viewpoint
      ul = UserLog.find(:first,:conditions=>"kind = '#{UserLog::EDIT_VIEWPOINT}' and user_id = #{self.id}",:order=>"id desc")
      return if ul.blank?
      Viewpoint.find_by_id(ul.info_hash["viewpoint_id"])
    end
  end

  module ChannelUserMethods
    def self.included(base)
      base.after_create :add_add_contact_user_log
    end

    def add_add_contact_user_log
      user = self.user
      channel = self.channel

      channels = channel.creator.channels_of_user(user)
      return true if (channels-[channel]).count != 0

      return true if channel.creator.last_add_contact_user == user

      channel.creator.create_add_contact_user_log(user)
      return true
    rescue Exception => ex
      p ex
      return true
    end
  end

  module FeedMethods
    def self.included(base)
      base.after_create :add_add_feed_log
      base.after_update :add_edit_feed_log
    end

    def add_add_feed_log
      self.creator.create_add_feed_log(self)
      return true
    rescue Exception => ex
      p ex
      return true
    end

    def add_edit_feed_log
      user = self.creator
      return true if user.last_edit_feed == self

      user.create_edit_feed_log(self)
      return true
    rescue Exception => ex
      p ex
      return true
    end
  end

  module ViewpointMethods
    def self.included(base)
      base.after_create :add_add_viewpoint_log
      base.after_update :add_edit_viewpoint_log
    end

    def add_add_viewpoint_log
      self.user.create_add_viewpoint_log(self)
      return true
    rescue Exception => ex
      p ex
      return true
    end

    def add_edit_viewpoint_log
      return true if self.changes["memo"].blank?
      return true if self.user.last_edit_viewpoint == self

      ul = UserLog.last_of_user(self.user)
      unless ul.blank?
        if ul.kind == UserLog::ADD_VIEWPOINT && ul.info.viewpoint.id == self.id
          return true
        end
      end

      self.user.create_edit_viewpoint_log(self)
      return true
    rescue Exception => ex
      p ex
      return true
    end
  end
end
