class Channel < UserAuthAbstract
  has_many :channel_users,:dependent=>:destroy
  has_many :include_users_db,:through=>:channel_users,:source=>:user,:order=>"channel_users.id desc"

  KIND_CHAT = "chat"                               # 闲聊
  KIND_BLOG = "blog"                               # 信息发布
  KIND_INTERVIEW = "interview"                     # 问答访谈
  KIND_MINDMAP_MANAGER = "mindmap"                 # 导图管理
  KIND_TODOLIST = "todolist"

  KIND_SHOW_NAME = Hash.new('聊天').merge({
    KIND_CHAT => '聊天',
    KIND_BLOG => '博客',
    KIND_INTERVIEW => '问答',
    KIND_MINDMAP_MANAGER => '导图',
    KIND_TODOLIST => '任务'
  })

  def kind_name
    KIND_SHOW_NAME[self.kind]
  end

  belongs_to :creator,:class_name=>"User",:foreign_key=>:creator_id

  validates_presence_of :name
  validates_presence_of :creator
  validates_uniqueness_of :name,:scope=>"creator_id"

  index :creator_id
  index [:creator_id,:id]

  def has_user_db?(user)
    include_users_db.include?(user)
  end

  def get_channel_user_obj_of(user)
    self.channel_users.find_by_user_id(user.id)
  end

  # 给频道增加一个联系人
  # 增加成功返回 true
  # 增加失败返回 false
  def add_user(user)
    channel_user = get_channel_user_obj_of(user)
    return if !channel_user.blank?
    ChannelUser.create(:user=>user,:channel=>self)
  end

  # 那一群人加到一个频道
  def add_users_on_queue(users)
    users.each do |user|
      ChannelUserOperationQueue.new.add_task(ChannelUserOperationQueue::ADD_OPERATION,self.id,user.id);
    end
  end

  # 把 user 从 频道去除
  # 去除成功返回 true
  # 失败或者 user 原本就不在频道 返回 false
  def remove_user(user)
    channel_user = get_channel_user_obj_of(user)
    channel_user.destroy if channel_user
  end

  module UserMethods
    def self.included(base)
      base.has_many :channels,:foreign_key=>:creator_id, :order => "position"
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

  module MindmapMethods
    # 待修改修改
#    def self.included(base)
#      base.extend ClassMethods
#    end
#    module ClassMethods
#      def channel_mindmaps(channel)
#        channel.contact_users.map do |user|
#          user.mindmaps.publics
#        end.compact.flatten.sort{|a,b|b.updated_at<=>a.updated_at}
#      end
#
#    end
  end
  include ChannelNewsFeedProxy::ChannelMethods

  include ChannelCacheProxy::ChannelMethods
  include FeedChannel::ChannelMethods
  include PositionMethods
end
