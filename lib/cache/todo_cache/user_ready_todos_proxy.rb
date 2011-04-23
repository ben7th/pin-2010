class UserReadyTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_ready_todos"
  end

  def xxxs_ids_db
    @user.ready_todos_db.map{|todo|todo.id}
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_create => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserReadyTodosProxy.new(user).add_to_cache(todo.id)
      },
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserReadyTodosProxy.new(user).remove_from_cache(todo.id)
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :ready_todos => Proc.new{|user|
        UserReadyTodosProxy.new(user).get_models(Todo)
      }
    }
  end
end
