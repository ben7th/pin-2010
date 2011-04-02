class Channel < ActiveRecord::Base
  has_many :channel_contacts,:dependent=>:destroy

  KIND_CHAT = "chat"                               # 闲聊
  KIND_BLOG = "blog"                               # 信息发布
  KIND_INTERVIEW = "interview"                     # 问答访谈
  KIND_MINDMAP_MANAGER = "mindmap"                 # 导图管理

  KIND_SHOW_NAME = Hash.new('聊天').merge({
    KIND_CHAT => '聊天',
    KIND_BLOG => '博客',
    KIND_INTERVIEW => '问答',
    KIND_MINDMAP_MANAGER => '导图'
  })

  def kind_name
    KIND_SHOW_NAME[self.kind]
  end

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_email,:primary_key=>:email

  validates_presence_of :name
  validates_presence_of :creator_email
  validates_format_of :creator_email,
    :with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/
  validates_uniqueness_of :name,:scope=>"creator_email"

  index :creator_email
  index [:creator_email,:id]

  before_create :set_position
  def set_position
    self.position = Time.now.to_i
  end

  def contacts
    self.channel_contacts.map{|cc|cc.contact}
  end

  def contact_users
    self.contacts.map{|c|c.follow_user}.reverse
  end

  def has_user?(user)
    contact_users.include?(user)
  end

  # 给频道增加一个联系人
  # 增加成功返回 true
  # 增加失败返回 false
  def add_user(user)
    contact = self.creator.get_contact_obj_of(user)
    if contact.blank?
      contact = self.creator.add_contact_user(user)
    end
    cc = ChannelContact.new(:contact=>contact,:channel=>self)
    cc.save
  end

  # 那一群人加到一个频道
  def add_users(users)
    users.each do |user|
      ChannelContactOperationQueue.new.add_task(ChannelContactOperationQueue::ADD_OPERATION,self.id,user.id);
    end
  end

  # 把 user 从 频道去除
  # 去除成功返回 true
  # 失败或者 user 原本就不在频道 返回 false
  def remove_user(user)
    contact = self.creator.get_contact_obj_of(user)
    return false if contact.blank?
    cc = ChannelContact.find_by_channel_id_and_contact_id(self.id,contact.id)
    return false if !cc
    cc.destroy
  end

  module UserMethods
    def self.included(base)
      base.has_many :channels,:foreign_key=>:creator_email,:primary_key=>:email, :order => "position"
    end

    def channels_count
      channels.count
    end

    def no_channel_contacts
      all_contacts = self.contacts
      ccs = all_contacts.map do |contact|
        ChannelContact.find_all_by_contact_id(contact.id)
      end.flatten.select{|cc|!cc.channel.blank?}
      has_channel_contacts = ccs.map{|cc|cc.contact}.uniq
      all_contacts-has_channel_contacts
    end

    def no_channel_contact_users_db
      no_channel_contacts.map{|c|c.follow_user}.compact
    end

    # self 是channel的拥有者 user是被查的人
    def channels_of_user_db(user)
      channel_contacts = self.channels.map do |channel|
        channel.channel_contacts
      end.flatten
      channel_contacts = channel_contacts.select{|cc|cc.contact.follow_user == user}
      channel_contacts = channel_contacts.sort{|cc1,cc2|cc1.updated_at<=>cc2.updated_at}
      channel_contacts.map{|cc|cc.channel}.uniq
    end

    def belongs_to_channels_db
      contacts = self.fans_contacts_db
      contacts.map do |contact|
        ChannelContact.find_all_by_contact_id(contact.id).map do |cc|
          cc.channel
        end
      end.flatten.compact.uniq
    end

    def to_sort_channels_by_ids(ids)
      raise "ids 的 channel_id 数量有错误" if self.channels.count != ids.count
      begin
        cs = Channel.find(ids)
        cs.each_with_index do |c,index|
          raise "ids 中 有不属于 user 的 channel" if c.creator != self
          c.position = index+1
          c.save if c.changed?
        end
      rescue ActiveRecord::RecordNotFound => ex
        raise "ids 中 有不存在的channel_id"
      end
    end
  end

  module MindmapMethods
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
      def channel_mindmaps(channel)
        channel.contact_users.map do |user|
          user.mindmaps.publics
        end.compact.flatten.sort{|a,b|b.updated_at<=>a.updated_at}
      end

      def no_channel_mindmaps_of(user)
        user.no_channel_contact_users.map do |user_tmp|
          user_tmp.mindmaps.publics
        end.compact.flatten.sort{|a,b|b.updated_at<=>a.updated_at}
      end
    end
  end
  include ChannelNewsFeedProxy::ChannelMethods

  include ChannelCacheProxy::ChannelMethods
  include FeedChannel::ChannelMethods
end
