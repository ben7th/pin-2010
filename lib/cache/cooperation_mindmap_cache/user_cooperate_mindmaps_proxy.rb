class UserCooperateMindmapsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_cooperate_mindmaps"
  end

  def xxxs_ids_db
    @user.cooperate_mindmaps_db.map{|mindmap|mindmap.id}
  end
end
