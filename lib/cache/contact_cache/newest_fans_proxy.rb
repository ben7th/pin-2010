class NewestFansProxy
  def initialize(user)
    @user = user
    @key = "refresh_newest_fans_id_#{user.email}"
    @redis = RedisCache.instance
    @fan_proxy = FanProxy.new(@user)
  end

  def newest_fans_ids(current_id = nil)
    current_id = newest_fans_id if current_id.nil?
    @fan_proxy.xxxs_ids.select{|id|id>(current_id.to_i)}
  end

  def newest_fans_id
    if !@redis.exists(@key)
      refresh_newest_fans_id
    end
    @redis.get(@key).to_i
  end

  def refresh_newest_fans_id
    id = @fan_proxy.xxxs_ids.first || 0
    @redis.set(@key,id)
  end

end
