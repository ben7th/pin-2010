class TodoUser < UserAuthAbstract

  belongs_to :todo
  belongs_to :user
  validates_presence_of :todo,:on=>:create
  validates_presence_of :user,:on=>:create
  validates_presence_of :memo
  validates_uniqueness_of :todo_id, :scope => :user_id
  
  def add_memo(memo)
    self.update_attributes(:memo=>memo)
  end

  def has_memo?
    !self.memo.blank?
  end

  def create_viewpoint_feed(user,content)
    Feed.create(:event=>Feed::SAY_OPERATE,
      :content=>content,:creator=>user,:from_viewpoint=>self.id)
  end

  after_create :remove_feed_invite
  after_update :remove_feed_invite
  def remove_feed_invite
    feed = self.todo.feed
    user = self.user
    return if feed.blank? || user.blank?
    fi = FeedInvite.find_by_feed_id_and_user_id(feed.id,user.id)
    fi.destroy unless fi.blank?
    return true
  end

  module UserMethods
    def self.included(base)
      base.has_many :todo_users
      base.has_many :viewpoints_db,:through=>:todo_users,
        :source=>:todo,:order=>"todo_users.updated_at desc"
    end

    # 我参与的话题
    def memoed_feeds_db
      self.viewpoints_db.map do |todo|
        todo.feed
      end.compact
    end

  end

  module TodoMethods
    def self.included(base)
      base.after_create :create_todo_user_for_channel_main_users
      base.has_many :todo_users,:order=>"todo_users.vote_score desc"
      base.has_many :memoed_users_db,:through=>:todo_users,:source=>:user,
        :conditions=>"todo_users.memo is not null",
        :order=>"todo_users.vote_score desc"
    end

    def create_todo_user_for_channel_main_users
      # 暂时去掉  2011.5.5 李飞
      # 频道内的 feed 对应的todo 创建的时候，不在默认创建频道成员的 todo_user
#      channels = self.feed.channels_db
#      channel = channels.first
#      return true if channel.blank?
#      self.add_executers(channel.main_users)
      return true
    end

    def get_todo_user_by_user(user)
      self.todo_users.find_by_user_id(user.id)
    end
    
    def create_or_update_viewpoint(user,content)
      tu = TodoUser.find_by_todo_id_and_user_id(self.id,user.id)
      if tu.blank?
        tu = TodoUser.create(:todo=>self,:user=>user,:memo=>content)
      else
        tu.add_memo(content)
      end
      return tu
    end
  end

  module FeedMethods
    # 创建对 feed 的观点
    def create_or_update_viewpoint(user,content)
      todo = self.get_or_create_first_todo
      todo.create_or_update_viewpoint(user,content)
    end

    def viewpoints
      ft = self.first_todo
      return [] if ft.blank?
      ft.todo_users
    end
    
    def memoed_viewpoints
      viewpoints.select{|vp|vp.has_memo?}
    end

    def viewpoint_of(user)
      todo = self.first_todo
      return if todo.blank?
      todo.get_todo_user_by_user(user)
    end

    def viewpoint_by?(user)
      todo = self.first_todo
      return false if todo.blank?
      todo_user = todo.get_todo_user_by_user(user)
      return false if todo_user.blank?
      todo_user.has_memo?
    end

    def has_viewpoint?
      viewpoints = self.viewpoints
      return false if viewpoints.blank?
      viewpoints.each do |todo_user|
        if todo_user.has_memo?
          return true
        end
      end
      return false
    end

    def hot_viewpoint
      self.viewpoints.first
    end

    def memoed_users
      memoed_users_db
    end

    # 参与的用户
    def memoed_users_db
      todo = self.first_todo
      return [] if todo.blank?
      todo.memoed_users_db
    end
  end

  include TodoMemoComment::TodoUserMethods
  include ShortUrl::TodoUserMethods
  include ViewpointVote::TodoUserMethods
  include UserAddViewpointTipProxy::TodoUserMethods
end
