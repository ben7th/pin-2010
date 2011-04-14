class UserDropTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_drop_todos"
  end

  def xxxs_ids_db
    @user.drop_todos_db.map{|todo|todo.id}
  end
end
