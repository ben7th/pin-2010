class MindmapFavUsersProxy < RedisBaseProxy
  def initialize(mindmap)
    @mindmap = mindmap
    @key = "mindmap_#{mindmap.id}_fav_users"
  end

  def xxxs_ids_db
    @mindmap.fav_users_db.map{|user|user.id}
  end
end
