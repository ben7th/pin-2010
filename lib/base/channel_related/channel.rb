class Channel < UserAuthAbstract
  has_many :channel_contacts
  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  validates_presence_of :name
  validates_presence_of :creator
  validates_uniqueness_of :name,:scope=>"creator_id"

  index :creator_id
  index [:creator_id,:id]

  def include_users_db
    User.find_by_sql(%`
      SELECT users.* FROM users
      INNER JOIN contacts ON contacts.follow_user_id = users.id
      INNER JOIN channel_contacts ON channel_contacts.contact_id = contacts.id
      WHERE channel_contacts.channel_id = #{self.id}
      `)
  end

  def has_user_db?(user)
    include_users_db.include?(user)
  end

  def get_channel_contact_obj_of(contact)
    self.channel_contacts.find_by_contact_id(contact.id)
  end

  # 给频道增加一个联系人
  # 增加成功返回 true
  # 增加失败返回 false
  def add_user(user)
    contact = self.creator.get_contact_obj_of(user)
    return false if contact.blank?

    channel_contact = get_channel_contact_obj_of(contact)
    return true if !channel_contact.blank?

    ChannelContact.create(:contact=>contact,:channel=>self)
    return true
  end

  # 那一群人加到一个频道
  def add_users_on_queue(users)
    users.each do |user|
      ChannelUserWorker.async_channel_user_operate(ChannelUserWorker::ADD_OPERATION,self.id,user.id);
    end
  end

  # 把 user 从 频道去除
  def remove_user(user)
    contact = self.creator.get_contact_obj_of(user)
    return false if contact.blank?

    channel_contact = get_channel_contact_obj_of(contact)
    channel_contact.destroy unless channel_contact.blank?
    return true
  end

  module UserMethods
    def self.included(base)
      base.has_many :channels,:foreign_key=>:creator_id
    end

    def channels_count
      channels.count
    end

    # user 是否在 self 的 任意 channels 内
    def channels_has_user?(user)
      self.channels.each do |channel|
        if channel.has_user_db?(user)
          return true
        end
      end
      return false
    end

    # self 是channel的拥有者 user是被查的人
    def channels_of_user_db(user)
      self_channels = self.channels
      user.belongs_to_channels_db.select do |channel|
        self_channels.include?(channel)
      end
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

  include FeedChannel::ChannelMethods
  include PositionMethods
  include CooperationChannel::ChannelMethods
end
