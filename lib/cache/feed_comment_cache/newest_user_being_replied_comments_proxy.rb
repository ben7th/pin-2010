# 对 user 发送的 feeds 的 最新的几条 feed_comments
class NewestUserBeingRepliedCommentsProxy
  def initialize(user)
    @user = user
    @key = "refresh_newest_user_being_replied_comment_id_#{user.email}"
    @redis = RedisCache.instance
    @ubrc_proxy = UserBeingRepliedCommentsProxy.new(@user)
  end

  def newest_comments_ids(current_id = nil)
    current_id = newest_comments_id if current_id.nil?
    @ubrc_proxy.xxxs_ids.select{|id|id>(current_id.to_i)}
  end

  def newest_comments_id
    if !@redis.exists(@key)
      refresh_newest_comments_id
    end
    @redis.get(@key).to_i
  end

  def refresh_newest_comments_id
    id = @ubrc_proxy.xxxs_ids.first || 0
    @redis.set(@key,id)
  end

end
