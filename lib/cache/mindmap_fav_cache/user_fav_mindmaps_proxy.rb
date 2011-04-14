class UserFavMindmapsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_fav_mindmaps"
  end

  def xxxs_ids_db
    @user.fav_mindmaps_db.map{|mindmap|mindmap.id}
  end
end
