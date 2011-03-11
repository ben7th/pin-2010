class ChannelContact < ActiveRecord::Base
  belongs_to :channel
  belongs_to :contact

  validates_presence_of :channel
  validates_presence_of :contact

  index :channel_id
  index :contact_id
  index [:contact_id,:channel_id]

  after_save :add_channel_users_cache
  def add_channel_users_cache
    ChannelCacheProxy.new(User.find_by_email(contact.email),channel).add
  end

  after_destroy :remove_channel_users_cache
  def remove_channel_users_cache
    ChannelCacheProxy.new(User.find_by_email(contact.email),channel).remove
  end

  def validate_on_create
    ccs = ChannelContact.find_all_by_channel_id_and_contact_id(self.channel_id,self.contact_id)
    errors.add(:base,"重复关联") if !ccs.blank?
  end

  module ContactMethods
    def self.included(base)
      base.has_many :channel_contacts,:dependent=>:destroy
    end
  end
end
