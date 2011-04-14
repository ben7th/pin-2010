class UserDoingTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_doing_todos"
  end

  def xxxs_ids_db
    @user.doing_todos_db.map{|todo|todo.id}
  end
end
