class UserTodosChangeStatusProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_assigned_todos_change_status"
    @utcs = RedisVectorArrayCache.new(@key)
  end

  def add(todo)
    if !@utcs.exists
      return @utcs.set([todo.id])
    end
    if !all.include?(todo.id)
      @utcs.push(todo.id)
    end
  end

  def remove(todo)
    @utcs.remove(todo.id)
  end

  def delete
    @utcs.delete
  end

  def all
    if !@utcs.exists
      return []
    end
    @utcs.all
  end

end
