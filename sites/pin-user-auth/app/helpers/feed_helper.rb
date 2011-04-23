module FeedHelper
  def activity_to_html(activity)
    begin
      operator = EmailActor.get_user_by_email(activity.operator)
      render :partial=>"activities/#{activity.event}",:locals=>{:activity=>activity,:operator=>operator}
    end
  rescue Exception => ex
    ex
  end

  def feed_content(feed)
    "#{auto_link(h(feed.content),:html=>{:target=>'_blank'})}"
  end

  def user_last_feed(user)
    feed = user.out_newest_feed
    return if feed.nil?
    feed_content(feed)
  end

  def channel_last_feed(channel)
    feed = channel.newest_feed
    return if feed.nil?
    user = feed.creator
    "#{link_to user.name,user} #{feed_content(feed)}"
  end

  def feed_preview(feed)
    ''
  end

  def misc_tip_info
    if logged_in?
      MessageTip.new(current_user).newest_info
    else
      Hash.new(0)
    end
  end

  def refresh_feed_tip
    MessageTip.new(current_user).refresh_feeds_info if logged_in?
  end

  def refresh_comment_tip
    MessageTip.new(current_user).refresh_comments_info if logged_in?
  end

  def refresh_quote_tip
    MessageTip.new(current_user).refresh_quotes_info if logged_in?
  end

  def refresh_todo_tip
    MessageTip.new(current_user).refresh_todos_info if logged_in?
  end

  def refresh_fans_tip
    MessageTip.new(current_user).refresh_fans_info if logged_in?
  end
end
