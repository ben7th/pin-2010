class Channel < ActiveRecord::Base
  has_many :channel_contacts
  #has_many :contacts,:through=>:channel_contacts

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_email,:primary_key=>:email

  validates_presence_of :name
  validates_presence_of :creator_email
  validates_format_of :creator_email,
    :with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/
  validates_uniqueness_of :name,:scope=>"creator_email"

  index :creator_email
  index [:creator_email,:id]

  def contacts
    self.channel_contacts.map{|cc|cc.contact}
  end

  def contact_users
    self.contacts.map{|c|EmailActor.get_user_by_email(c.email)}.reverse
  end

  def has_user?(user)
    contact_users.include?(user)
  end

  # 给频道增加一个联系人
  # 增加成功返回 true
  # 增加失败返回 false
  def add_user(user)
    contacts = self.creator.contacts.find_all_by_email(user.email)
    contact = contacts.first
    if contacts.blank?
      contact = self.creator.contacts.new(:email=>user.email)
      contact.save
    end
    cc = ChannelContact.new(:contact=>contact,:channel=>self)
    cc.save
  end

  # 把 user 从 频道去除
  # 去除成功返回 true
  # 失败或者 user 原本就不在频道 返回 false
  def remove_user(user)
    contacts = self.creator.contacts.find_all_by_email(user.email)
    return false if contacts.blank?
    contact = contacts.first
    cc = ChannelContact.find_by_channel_id_and_contact_id(self.id,contact.id)
    return false if !cc
    cc.destroy
  end

  module UserMethods
    def self.included(base)
      base.has_many :channels,:foreign_key=>:creator_email,:primary_key=>:email
    end

    def no_channel_contacts
      self.contacts.select do |contact|
        contact.channel_contacts.count == 0
      end.reverse
    end

    def no_channel_contact_users
      no_channel_contacts.map{|c|EmailActor.get_user_by_email(c.email)}.compact
    end

    def channels_of(user)
      channel_contacts = self.channels.map do |channel|
        channel.channel_contacts
      end.flatten
      channel_contacts = channel_contacts.select{|cc|cc.contact.email == user.email}
      channel_contacts = channel_contacts.sort{|cc1,cc2|cc1.updated_at<=>cc2.updated_at}
      channel_contacts.map{|cc|cc.channel}.uniq
    end
  end
end
