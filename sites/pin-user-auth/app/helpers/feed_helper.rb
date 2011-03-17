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
#    "<span class='loud'>#{feed.event.upcase}</span> #{feed.content}"
    "<span class='loud'>说</span> #{feed.content}"
  end

  def user_last_feed(user)
    feed = user.news_feed_proxy.own_newest_feed
    return if feed.nil?
    feed_content(feed)
  end

  def feed_preview(feed)
    ''
  end
end
