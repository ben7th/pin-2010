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

    # 把 todo_id 对应的任务放在最前面
    def set_todo_to_first_of_assigned_todos(todo_id)
      todo_id = todo_id.to_i
      ids = _assert_assigned_todos_ids_include_todo_id_and_return_assigned_todos_ids(todo_id)
      return if ids.first == todo_id
      
      first_todo = Todo.find(ids.first)
      todo = Todo.find(todo_id)
      first_position = first_todo.position
      todo.update_attributes(:position=>first_position+1)

      # 更新缓存
      ids.delete(todo_id)
      new_ids = ids.unshift(todo_id)
      _change_sort_of_assigned_todos_ids(new_ids)
    end

    # 把 todo_id 对应的任务和它后边的任务换位置
    def set_todo_to_down_of_assigned_todos(todo_id)
      todo_id = todo_id.to_i
      ids = _assert_assigned_todos_ids_include_todo_id_and_return_assigned_todos_ids(todo_id)

      todo_index = ids.index(todo_id)
      next_todo_index = todo_index+1
      next_todo_id = ids[next_todo_index]
      return if next_todo_id.blank?

      _swap_two_todos_position(todo_id,next_todo_id)
      new_ids = _swap_two_item_on_array(ids,todo_index,next_todo_index)
      _change_sort_of_assigned_todos_ids(new_ids)
    end

    # 把 todo_id 对应的任务和它前面的任务换位置
    def set_todo_to_up_of_assigned_todos(todo_id)
      todo_id = todo_id.to_i
      ids = _assert_assigned_todos_ids_include_todo_id_and_return_assigned_todos_ids(todo_id)

      todo_index = ids.index(todo_id)
      prev_todo_index = todo_index-1
      return if prev_todo_index < 0
      prev_todo_id = ids[prev_todo_index]
      return if prev_todo_id.blank?
      _swap_two_todos_position(todo_id,prev_todo_id)
      new_ids = _swap_two_item_on_array(ids,todo_index,prev_todo_index)
      _change_sort_of_assigned_todos_ids(new_ids)
    end

    def _swap_two_todos_position(todo_id,other_todo_id)
      todo = Todo.find(todo_id)
      other_todo = Todo.find(other_todo_id)
      todo_user = self.get_todo_user_by_todo(todo)
      next_todo_user = self.get_todo_user_by_todo(other_todo)
      tp = todo_user.position
      ntp = next_todo_user.position
      todo_user.update_attributes(:position=>ntp)
      next_todo_user.update_attributes(:position=>tp)
    end

    def _swap_two_item_on_array(array,index,other_index)
      new_array = array.clone
      other_item = new_array[other_index]
      item = new_array[index]
      new_array[index] = other_item
      new_array[other_index] = item
      return new_array
    end

    def _assert_assigned_todos_ids_include_todo_id_and_return_assigned_todos_ids(todo_id)
      ids = self.assigned_todos_db.map{|todo|todo.id}
      raise "用户的assigned_todos_ids 中没有这个todo_id" if !ids.include?(todo_id)
      return ids
    end

    def to_sort_todos_by_ids(todo_ids)
      raise "todo_ids 数量有错误" if self.assigned_todos.length != todo_ids.length
      raise "todo_ids 中 有不属于 user 的 todo" if (todo_ids|self.assigned_todos_ids) != todo_ids
      begin
        todos = Todo.find(todo_ids)
        todos.each_with_index do |todo,index|
          todo_user = self.get_todo_user_by_todo(todo)
          todo_user.positon = index+1
          todo_user.save if todo_user.changed?
        end
        self.change_sort_of_assigned_todos_ids(todo_ids)
      rescue ActiveRecord::RecordNotFound => ex
        raise "todo_ids 中 有不存在的 todo"
      end
    end

    def _change_sort_of_assigned_todos_ids(todos_ids)
      UserAssignedTodosProxy.new(self).change_sort(todos_ids)
    end

  end

  module TodoMethods
    def self.included(base)
      base.after_create :create_todo_user_for_channel_main_users
      base.has_many :todo_users
      base.has_many :executers,:through=>:todo_users,:source=>:user
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

  include PositionMethods
  include TodoMemoComment::TodoUserMethods
end
