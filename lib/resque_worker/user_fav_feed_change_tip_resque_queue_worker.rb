class UserFavFeedChangeTipResqueQueueWorker
  @queue = :user_fav_feed_change_tip_resque_queue

  def self.async_user_fav_feed_change_tip(feed_id,operater_id,kind)
    Resque.enqueue(UserFavFeedChangeTipResqueQueueWorker,feed_id,operater_id,kind)
  end

  def self.perform(feed_id,operater_id,kind)
    return true if feed_id == "wake_up"
    feed = Feed.find_by_id(feed_id)
    user = User.find_by_id(operater_id)
    return true if feed.blank? || user.blank?
    UserFavFeedChangeTipProxy.add_tip(feed,user,kind)
  end
end
