class NewestUserBeAskedFeedsProxy
  def initialize(user)
    @user = user
    @key = "refresh_newest_user_#{@user.id}_be_asked_feeds"
    @redis = RedisCache.instance
    @ubaf_proxy = UserBeAskedFeedsProxy.new(@user)
  end
  
  def newset_feeds_ids(current_id = nil)
    current_id = newest_feeds_id if current_id.nil?
    all_ids = @ubaf_proxy.xxxs_ids
    index = all_ids.index(current_id)
    return all_ids if index.blank?
    return all_ids[0...index]
  end
  
  def newest_feeds_id
    if !@redis.exists(@key)
      refresh_newest_feeds_id
    end
    @redis.get(@key).to_i
  end

  def refresh_newest_feeds_id
    id = @ubaf_proxy.xxxs_ids.first || 0
    @redis.set(@key,id)
  end
end
