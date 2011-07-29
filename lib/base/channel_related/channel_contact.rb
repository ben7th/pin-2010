class ChannelContact < UserAuthAbstract
  belongs_to :channel
  belongs_to :contact
  validates_presence_of :channel
  validates_presence_of :contact
  validates_uniqueness_of :contact_id, :scope => :channel_id

  index :channel_id
  index :contact_id
  index [:contact_id,:channel_id]

  module ChannelMethods
    def self.included(base)
      base.has_many :channel_contacts,:dependent=>:destroy
    end
  end

  module ContactMethods
    def self.included(base)
      base.has_many :channel_contacts,:dependent=>:destroy
    end
  end

  module UserMethods
    def belongs_to_channels_db
      Channel.find_by_sql(%`
        SELECT channels.* FROM channels
        INNER JOIN channel_contacts ON channel_contacts.channel_id = channels.id
        INNER JOIN contacts ON contacts.id = channel_contacts.contact_id
        WHERE contacts.follow_user_id = #{self.id}
        `)
    end
  end
end
