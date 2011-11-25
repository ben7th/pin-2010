module UserTipBeFollowedMethods
  def self.included(base)
    base.add_enabled_kinds(UserTip::BE_FOLLOWED)
    base.add_rules({
      :class => ChannelUser,
      :after_create => Proc.new{|channel_user|
        user = channel_user.user
        fan = channel_user.channel.creator
        
        Resque.enqueue(UserTipResqueHandler, UserTipResqueHandler::CHANNEL_USER_CREATED, [user.id, fan.id])
      },
      :after_destroy => Proc.new{|channel_user|
        user = channel_user.user
        fan = channel_user.channel.creator

        Resque.enqueue(UserTipResqueHandler, UserTipResqueHandler::CHANNEL_USER_REMOVED, [user.id, fan.id])
      }
    })
  end

  # 尝试创建“被关注”通知，此方法不会重复创建通知
  def create_be_followed_tip(fan)
    return if !fan.following?(@user)

    tip_data = {"fan_id"=>fan.id, "kind"=>UserTip::BE_FOLLOWED}
    tip_id = tip_data.hash

    @redis_cache.set tip_id,tip_data.merge("time"=>Time.now.to_f.to_s)
  end

  # 尝试取消“被关注”通知，此方法会进行逻辑判断，以确定是否可以取消通知
  def remove_be_followed_tip(fan)
    return if fan.following?(@user)

    tip_data = {"fan_id"=>fan.id, "kind"=>UserTip::BE_FOLLOWED}
    tip_id = tip_data.hash

    @redis_cache.remove tip_id
  end
end
