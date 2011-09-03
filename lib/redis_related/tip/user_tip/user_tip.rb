class UserTip
  BE_FOLLOWED = "be_followed"

  def initialize(user,attrs_hash)
    @user = user
    @attrs_hash = attrs_hash
  end

  # 动态方法，用于获取不同通知类型对象的属性值
  def method_missing_with_find_attr(symbol, *args)
    attr = @attrs_hash[symbol]
    if attr.blank?
      method_missing_without_find_attr(symbol, *args)
    else
      attr
    end
  end
  alias_method_chain :method_missing, :find_attr

  
  def remove
    @user.tip_proxy.remove_tip_by_id(id)
  end

  def self.build(user, tip_id, tip_data)
    attrs_hash = case tip_data["kind"]
      when BE_FOLLOWED
        self.build_be_followed_tip(tip_id, tip_data)
      end
      
    return if attrs_hash.blank?
    self.new(user,attrs_hash)
  end
  
  def self.build_be_followed_tip(tip_id, tip_data)
    channel_user = ChannelUser.find_by_id(tip_data["channel_user_id"])
    return if channel_user.blank?

    channel = channel_user.channel
    return if channel.blank?
    
    user = channel.creator
    kind = tip_data["kind"]
    time = Time.at(tip_data["time"].to_f)
    
    {:id=>tip_id, :user=>user, :kind=>kind, :time=>time}
  end
  
end
