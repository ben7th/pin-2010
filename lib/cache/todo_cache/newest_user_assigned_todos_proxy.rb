# 用户被指派的 todos 最新的几条
class NewestUserAssignedTodosProxy
  def initialize(user)
    @user = user
    @key = "refresh_newest_user_#{@user.id}_assigned_todos"
    @redis = RedisCache.instance
    @uat_proxy = UserAssignedTodosProxy.new(@user)
  end
  
  def newset_todos_ids(current_id = nil)
    current_id = newest_todos_id if current_id.nil?
    all_ids = @uat_proxy.xxxs_ids
    index = all_ids.index(current_id)
    return all_ids if index.blank?
    return all_ids[0...index]
  end
  
  def newest_todos_id
    if !@redis.exists(@key)
      refresh_newest_todos_id
    end
    @redis.get(@key).to_i
  end

  def refresh_newest_todos_id
    id = @uat_proxy.xxxs_ids.first || 0
    @redis.set(@key,id)
  end
end
