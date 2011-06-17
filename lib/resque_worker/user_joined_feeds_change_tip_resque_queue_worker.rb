class UserJoinedFeedsChangeTipResqueQueueWorker
  @queue = :user_joined_feeds_change_tip_resque_queue

  def self.async_tip(feed_id,user_ids)
    Resque.enqueue(UserJoinedFeedsChangeTipResqueQueueWorker,feed_id,user_ids)
  end

  def self.perform(feed_id,user_ids)
    return true if feed_id == "wake_up"

    users = user_ids.map{|id|User.find_by_id(id)}.compact
    UserJoinedFeedsChangeTipProxy.add_change_tip(feed_id,users)
  end
end
