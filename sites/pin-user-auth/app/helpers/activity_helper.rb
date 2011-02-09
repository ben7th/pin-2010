module ActivityHelper
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
      url = pin_url_for('pin-mindmap-editor',"mindmaps/#{json["mindmap_id"]}")
      "<span class=''>编辑了思维导图</span> #{link_to(json["mindmap_title"],url,:target=>'_blank')}"
    else
      "<span class='loud'>#{event.upcase}</span> #{feed.detail}"
    end
  end
end
