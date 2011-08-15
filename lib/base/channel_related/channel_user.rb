class ChannelUser < UserAuthAbstract
  belongs_to :channel
  belongs_to :user
  validates_presence_of :channel
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => :channel_id

  index :channel_id
  index :user_id
  index [:user_id,:channel_id]

  module ChannelMethods
    def self.included(base)
      base.has_many :channel_users,:dependent=>:destroy
      base.has_many :include_users_db,
        :through=>:channel_users,:source=>:user,
        :order=>"channel_users.id desc"
    end

    def has_user_db?(user)
      include_users_db.include?(user)
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :channel_users
      base.has_many :belongs_to_channels_db,
        :through=>:channel_users,:source=>:channel,
        :order=>"channel_users.id desc"
    end

    def fans_db
      UserAuthAbstract.connection.select_rows(%`
          select users.id from users
            inner join channels on channels.creator_id = users.id
            inner join channel_users on channel_users.channel_id = channels.id
          where channel_users.user_id = #{self.id}
          order by channel_users.id asc
        `).flatten.uniq.reverse.map{|id|User.find(id)}
    end

    def followings_db
      UserAuthAbstract.connection.select_rows(%`
          select users.id from users
            inner join channel_users on users.id = channel_users.user_id
            inner join channels on channel_users.channel_id = channels.id
          where channels.creator_id = #{self.id}
          order by channel_users.id asc
        `).flatten.uniq.reverse.map{|id|User.find(id)}
    end
  end

  include UserLog::ChannelUserMethods
end
