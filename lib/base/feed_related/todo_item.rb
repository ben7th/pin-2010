class TodoItem < UserAuthAbstract
  belongs_to :todo
  validates_presence_of :todo
  validates_presence_of :content

  module TodoMethods
    def self.included(base)
      base.has_many :todo_items,:order=>"id desc"
    end

    def create_todo_item(content)
      todo_item = TodoItem.create(:todo=>self,:content=>content)
      if !todo_item.new_record?
        # 如果todo添加item成功了，就添加todo id 到 到用户 的 “状态改变的todo任务列表中”
        todo_item.todo.todo_users.each do |todo_user|
          todo_user.add_todo_to_user_change_status_todos
        end
      end
      todo_item.valid?
    end

    def remove_last_todo_item
      todo_item = self.todo_items.last
      todo_item.destroy if todo_item
    end
  end
end
