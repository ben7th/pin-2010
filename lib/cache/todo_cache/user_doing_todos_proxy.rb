class UserDoingTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_doing_todos"
  end

  def xxxs_ids_db
    @user.doing_todos_db.map{|todo|todo.id}
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserDoingTodosProxy.new(user).remove_from_cache(todo.id)
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :doing_todos => Proc.new{|user|
        UserDoingTodosProxy.new(user).get_models(Todo)
      }
    }
  end
end
