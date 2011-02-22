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
    event = feed.event
    re = case event
    when 'edit_mindmap'
      json = ActiveSupport::JSON.decode(feed.detail)
      url = pin_url_for('pin-mev6',"mindmaps/#{json["mindmap_id"]}")
      %~
        <span class=''>编辑思维导图</span> #{link_to(json["mindmap_title"],url,:target=>'_blank')}
      ~
    else
      "<span class='loud'>#{event.upcase}</span> #{feed.detail}"
    end
  end

  def user_last_feed(user)
    feed = user.news_feed_proxy.own_newest_feed
    return if feed.nil?
    feed_content(feed)
  end

  def feed_preview(feed)
    event = feed.event
    re = case event
    when 'edit_mindmap'
      begin
        json = ActiveSupport::JSON.decode(feed.detail)
        mindmap = Mindmap.find(json["mindmap_id"])
        mindmap_image(mindmap,'120x120')
      rescue Exception => ex
        ''
      end
    else
      ''
    end
  end
end
