class UserDropTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_drop_todos"
  end

  def xxxs_ids_db
    @user.drop_todos_db.map{|todo|todo.id}
  end

  def self.rules
    {
      :class => TodoUser ,
      :after_destroy => Proc.new {|todo_user|
        user = todo_user.user
        todo = todo_user.todo
        next if user.blank? || todo.blank?
        UserDropTodosProxy.new(user).remove_from_cache(todo.id)
      }
    }
  end

  def self.funcs
    {
      :class => User,
      :drop_todos => Proc.new{|user|
        UserDropTodosProxy.new(user).get_models(Todo)
      },
      :drop_tods_ids => Proc.new{|user|
        UserDropTodosProxy.new(user).xxxs_ids
      }
    }
  end
end
