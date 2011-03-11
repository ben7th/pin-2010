class NoChannelUsersProxy
  def initialize(user)
    @user = user
    @no_channel_users_key = "user_#{@user.id}_no_channel_user_ids"
    @rmq_dcuk = RedisVectorArrayCache.new(@no_channel_users_key)
  end

  def no_channel_contact_users
    if !@rmq_dcuk.exists
      reload_redis
    end
    user_ids = @rmq_dcuk.all
    user_ids.map{|id|User.find_by_id(id)}
  end

  # 关注联系人的时候
  # 添加到默认的频道中
  def add_contact(contact)
    if !@rmq_dcuk.exists
      return reload_redis
    end
    @rmq_dcuk.push(User.find_by_email(contact.email).id)
  end

  # 取消关注联系人的时候
  # 从所有频道中删除
  def remove_contact(contact)
    if !@rmq_dcuk.exists
      return reload_redis
    end
    @rmq_dcuk.remove(User.find_by_email(contact.email).id)
  end

  def reload_redis
    user_ids = @user.no_channel_contact_users.map {|user|user.id}
    @rmq_dcuk.set(user_ids)
  end
  
end
