# 用户被指派的 todo
class UserAssignedTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_assigned_todos"
  end

  def xxxs_ids_db
    @user.assigned_todos_db.map{|todo|todo.id}
  end

  def change_sort(todos_ids)
    reset_cache(todos_ids)
  end
  
end
