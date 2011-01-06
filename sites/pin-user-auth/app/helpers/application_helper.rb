# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def preview_email(method)
    render :partial=>"mailer/#{method}",:locals=>{:preview=>true,:sender=>current_user}
  end
end
