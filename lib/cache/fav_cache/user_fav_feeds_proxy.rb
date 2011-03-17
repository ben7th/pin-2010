class UserFavFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_fav_feeds"
  end

  def xxxs_ids_db
    @user.fav_feeds_db.map{|feed|feed.id}
  end
end
