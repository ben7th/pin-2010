class TodoUser < UserAuthAbstract

  STATUS_READY = "ready"
  STATUS_DOING = "doing"
  STATUS_DONE = "done"
  STATUS_DROP = "drop"
  
  STATUS_SHOW_NAME = Hash.new("预备").merge({
      STATUS_READY => "预备",
      STATUS_DOING => "执行",
      STATUS_DONE => "完成",
      STATUS_DROP => "放弃"
    })

  belongs_to :todo
  belongs_to :user
  validates_presence_of :todo,:on=>:create
  validates_presence_of :user,:on=>:create
  validates_uniqueness_of :todo_id, :scope => :user_id
  
  def status_name
    STATUS_SHOW_NAME[self.status]
  end

  def show_status
    self.status || STATUS_READY
  end

  def change_status(status)
    if TodoUser::STATUS_SHOW_NAME.keys.include?(status)
      self.update_attributes(:status=>status)
    end
  end

  def has_memo?
    !self.memo.blank?
  end

  def add_memo(memo)
    self.update_attributes(:memo=>memo)
  end

  def clear_memo
    self.update_attributes(:memo=>"")
  end

  def create_viewpoint_feed(user,content)
    Feed.create(:event=>Feed::SAY_OPERATE,
      :content=>content,:creator=>user,:from_viewpoint=>self.id)
  end

  module UserMethods
    def self.included(base)
      base.has_many :todo_users
      base.has_many :assigned_todos_db,:through=>:todo_users,
        :source=>:todo,:order=>"todo_users.position desc"
      base.has_many :ready_todos_db,:through=>:todo_users,
        :conditions=>"todo_users.status is null or todo_users.status = '#{TodoUser::STATUS_READY}'",
        :source=>:todo,:order=>"todo_users.position desc"
      base.has_many :doing_todos_db,:through=>:todo_users,
        :conditions=>"todo_users.status = '#{TodoUser::STATUS_DOING}'",
        :source=>:todo,:order=>"todo_users.position desc"
      base.has_many :done_todos_db,:through=>:todo_users,
        :conditions=>"todo_users.status = '#{TodoUser::STATUS_DONE}'",
        :source=>:todo,:order=>"todo_users.position desc"
      base.has_many :drop_todos_db,:through=>:todo_users,
        :conditions=>"todo_users.status = '#{TodoUser::STATUS_DROP}'",
        :source=>:todo,:order=>"todo_users.position desc"

      base.has_many :memoed_todos_db,:through=>:todo_users,
        :source=>:todo,:order=>"todo_users.updated_at desc",
        :conditions=>"todo_users.memo is not null"
      base.has_many :be_asked_todos_db,:through=>:todo_users,
        :source=>:todo,:order=>"todo_users.updated_at desc",
        :conditions=>"todo_users.memo is null"
    end

    def get_todo_user_by_todo(todo)
      self.todo_users.find_by_todo_id(todo.id)
    end

    def get_or_create_todo_user_by_todo(todo)
      todo_user = self.todo_users.find_by_todo_id(todo.id)
      if todo_user.blank?
        todo_user = TodoUser.create(:todo=>todo,:user=>self)
      end
      todo_user
    end

  end

  module TodoMethods
    def self.included(base)
      base.after_create :create_todo_user_for_channel_main_users
      base.has_many :todo_users,:order=>"todo_users.vote_score desc"
      base.has_many :executers,:through=>:todo_users,:source=>:user
      base.has_many :memoed_users_db,:through=>:todo_users,:source=>:user,
        :conditions=>"todo_users.memo is not null"
      base.has_many :be_asked_users_db,:through=>:todo_users,:source=>:user,
        :conditions=>"todo_users.memo is null"
    end

    def create_todo_user_for_channel_main_users
      channels = self.feed.channels_db
      channel = channels.first
      return true if channel.blank?
      self.add_executers(channel.main_users)
      return true
    end

    # 分配 todo 给 users
    def add_executers(users)
      add_users = users - self.executers
      add_users.each do |user|
        TodoUser.create(:todo=>self,:user=>user)
      end
    end

    # 分配 todo 给 user
    def add_executer(user)
      return if self.executers.include?(user)
      TodoUser.create(:todo=>self,:user=>user)
    end

    # 取消 user 这个执行者
    def remove_executer(user)
      todo_user = user.get_todo_user_by_todo(self)
      todo_user.destroy if todo_user
    end

    def change_status_by(user,status)
      raise "user 没有被分配这个 todo" if !user.assigned_todos_ids.include?(self.id)
      todo_user = user.get_todo_user_by_todo(self)
      todo_user.change_status(status)
    end

    # user 对这个 todo 的执行状态
    def execute_status_name_of(user)
      raise "user 没有被分配这个 todo" if !user.assigned_todos_ids.include?(self.id)
      todo_user = user.get_todo_user_by_todo(self)
      todo_user.status_name
    end

    # user 对这个 todo 的执行状态
    def execute_status_of(user)
      raise "user 没有被分配这个 todo" if !user.assigned_todos_ids.include?(self.id)
      todo_user = user.get_todo_user_by_todo(self)
      todo_user.show_status
    end

    def add_memo(user,memo)
      todo_user = user.get_todo_user_by_todo(self)
      return false if todo_user.blank?
      todo_user.add_memo(memo)
    end

    def clear_memo(user)
      todo_user = user.get_todo_user_by_todo(self)
      return false if todo_user.blank?
      todo_user.clear_memo
    end

    def memo_by?(user)
      todo_user = user.get_todo_user_by_todo(self)
      return false if todo_user.blank?
      !todo_user.memo.blank?
    end

    def memo_content_by(user)
      if self.memo_by?(user)
        todo_user = user.get_todo_user_by_todo(self)
        return todo_user.memo
      end
      return ""
    end
  end

  include TodoMemoComment::TodoUserMethods
  include ShortUrl::TodoUserMethods
  include ViewpointVote::TodoUserMethods
end
