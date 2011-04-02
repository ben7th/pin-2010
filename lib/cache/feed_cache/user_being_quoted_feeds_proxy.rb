# 传阅user发送的feeds 的 所有feeds
class UserBeingQuotedFeedsProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{user.id}_being_quoted_feeds"
  end

  def xxxs_ids_db
    feed_ids = Feed.news_feeds_of_user(@user).map{|feed|feed.id}
    Feed.find(:all,:conditions => [ "quote_of IN (?)",feed_ids]).map do |feed|
      feed.id
    end.sort{|x,y| y<=>x}
  end

  module UserMethods
    def being_quoted_feeds
      ids = UserBeingQuotedFeedsProxy.new(self).xxxs_ids
      ids.map{|id|Feed.find_by_id(id)}.compact
    end
  end
end
