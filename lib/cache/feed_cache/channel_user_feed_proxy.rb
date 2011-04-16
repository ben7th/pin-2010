class ChannelUserFeedProxy
  def initialize(user,channel)
    key = "user_#{user.id}_channel_#{channel.id}_newest_feed"
    @vector_cache = RedisVectorArrayCache.new(key)
    @channel = channel
  end

  def newest_feed_id
    refresh_newest_feeds_id if !@vector_cache.exists
    return @vector_cache.all.first if !@vector_cache.all.blank?
  end

  def refresh_newest_feeds_id
    if !@channel.feeds.blank?
      @vector_cache.set([@channel.feeds.first.id])
    end
  end

  def newest_feeds_ids(current_id = nil)
    current_id = newest_feed_id if current_id.nil?
    @channel.feeds.map{|feed|feed.id}.select{|id|id>(current_id.to_i)}
  end
end
