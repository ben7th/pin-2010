class FeedFavUsersProxy < RedisBaseProxy
  def initialize(feed)
    @feed = feed
    @key = "feed_#{feed.id}_fav_users"
  end

  def xxxs_ids_db
    @feed.fav_users_db.map{|user|user.id}
  end
end
