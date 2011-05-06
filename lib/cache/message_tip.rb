class MessageTip
  def initialize(user)
    @user = user
  end

  def newest_info
    feeds_count = NewestUserInboxFeedProxy.new(@user).newest_feeds_ids.length
    fans_count = NewestFansProxy.new(@user).newest_fans_ids.length
    comments_count = NewestUserBeingRepliedCommentsProxy.new(@user).newest_comments_ids.length
    quotes_count = NewestUserBeingQuotedFeedsProxy.new(@user).newest_feeds_ids.length
    message_count =  MessageProxy.new(@user).unread_message_count
    {
      :feeds=>feeds_count,
      :fans=>fans_count,
      :comments=>comments_count,
      :quotes=>quotes_count,
      :messages=>message_count
    }
  end

  def refresh_feeds_info
    NewestUserInboxFeedProxy.new(@user).refresh_newest_feeds_id
  end

  def refresh_fans_info
    NewestFansProxy.new(@user).refresh_newest_fans_id
  end

  def refresh_comments_info
    NewestUserBeingRepliedCommentsProxy.new(@user).refresh_newest_comments_id
  end

  def refresh_quotes_info
    NewestUserBeingQuotedFeedsProxy.new(@user).refresh_newest_feeds_id
  end

  def newest_feeds(current_id = nil)
    NewestUserInboxFeedProxy.new(@user).newest_feeds_ids(current_id).map{|id|Feed.find_by_id(id)}.compact
  end

end
