# 对 user 发送的 feeds 的 最新的几条 传阅feed
class NewestUserBeingQuotedFeedsProxy
  def initialize(user)
    @user = user
    @key = "refresh_newest_user_being_quoted_feed_id_#{user.id}"
    @redis = RedisCache.instance
    @ubqf_proxy = UserBeingQuotedFeedsProxy.new(@user)
  end

  def newest_feeds_ids(current_id = nil)
    current_id = newest_feeds_id if current_id.nil?
    @ubqf_proxy.xxxs_ids.select{|id|id>(current_id.to_i)}
  end

  def newest_feeds_id
    if !@redis.exists(@key)
      refresh_newest_feeds_id
    end
    @redis.get(@key).to_i
  end

  def refresh_newest_feeds_id
    id = @ubqf_proxy.xxxs_ids.first || 0
    @redis.set(@key,id)
  end
end
