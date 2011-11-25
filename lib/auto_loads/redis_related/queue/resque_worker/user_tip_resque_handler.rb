class UserTipResqueHandler
  @queue = :user_tip_resque_queue

  CHANNEL_USER_CREATED = 'channel_user_created'
  CHANNEL_USER_REMOVED = 'channel_user_removed'

  # 逻辑尽可能交给队列去处理，不要把逻辑一半写在队列之外，一半写在队列之内
  def self.perform(operate, args)
    return true if operate == "wake_up"
    
    case operate
    when CHANNEL_USER_CREATED
      user = User.find(args[0])
      fan = User.find(args[1])
      user.tip_proxy.create_be_followed_tip(fan)
    when CHANNEL_USER_REMOVED
      user = User.find(args[0])
      fan = User.find(args[1])
      user.tip_proxy.remove_be_followed_tip(fan)
    end
  end
  
end