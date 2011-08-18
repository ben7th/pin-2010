class UserTipResqueQueueWorker
  @queue = :user_tip_resque_queue

  def self.async_user_tip(kind,args)
    Resque.enqueue(UserTipResqueQueueWorker,kind,args)
  end

  def self.perform(kind,args)
    return true if kind == "wake_up"
    UserTipProxy.create_tip(kind,args)
  end
end
