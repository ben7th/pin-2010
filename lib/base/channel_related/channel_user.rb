class ChannelUser < UserAuthAbstract
  belongs_to :channel
  belongs_to :user
  validates_presence_of :channel
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => :channel_id

  index :channel_id
  index :user_id
  index [:user_id,:channel_id]

  module UserMethods
    def self.included(base)
      base.has_many :channel_users,:dependent=>:destroy
      base.has_many :belongs_to_channels_db,:through=>:channel_users,:source=>:channel,:order=>"channel_users.id desc"
    end
  end

  include ChannelCacheProxy::ChannelUserMethods
end
