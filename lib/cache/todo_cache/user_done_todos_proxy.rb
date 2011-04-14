class UserDoneTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_done_todos"
  end

  def xxxs_ids_db
    @user.done_todos_db.map{|todo|todo.id}
  end
end
