class UserDoneTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_done_todos"
  end

  def xxxs_ids_db
    @user.done_todos_db.map{|todo|todo.id}
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserDoneTodosProxy.new(user).remove_from_cache(todo.id)
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :done_todos => Proc.new{|user|
        UserDoneTodosProxy.new(user).get_models(Todo)
      }
    }
  end
end
