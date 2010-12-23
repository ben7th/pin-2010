module ActivityHelper
  def activity_to_html(activity)
    begin
      operator = User.find_by_email(activity.operator)
      render :partial=>"activities/#{activity.event}",:locals=>{:activity=>activity,:operator=>operator}
    end
  rescue Exception => ex
    ex
  end
end
