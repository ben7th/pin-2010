class Channel < UserAuthAbstract
  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  validates_presence_of :name
  validates_presence_of :creator
  validates_uniqueness_of :name,:scope=>"creator_id"

  index :creator_id
  index [:creator_id,:id]

  # 给频道增加一个联系人
  # 增加成功返回 true
  # 增加失败返回 false
  def add_user(user)
    return if user.blank? || self.creator == user
    cu = ChannelUser.find_by_channel_id_and_user_id(self.id,user.id)
    cu = ChannelUser.create(:channel=>self,:user=>user) if cu.blank?
    return cu
  end

  # 那一群人加到一个频道
  def add_users(users)
    users.each{|user| self.add_user(user)}
  end

  # 把 user 从 频道去除
  def remove_user(user)
    cus = ChannelUser.find_all_by_channel_id_and_user_id(self.id,user.id)
    cus.each{|cu|cu.destroy}
  end

  module UserMethods
    def self.included(base)
      base.has_many :channels_db,:class_name=>"Channel",:foreign_key=>:creator_id
    end

    def channels_count
      channels.count
    end

    # self 是channel的拥有者 user是被查的人
    def channels_of_user_db(user)
      user.belongs_to_channels_db & self.channels_db
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

  include PositionMethods
  include CooperationChannel::ChannelMethods
  include SendScope::ChannelMethods
  include ChannelUser::ChannelMethods
end
