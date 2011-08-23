# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def return_to_homepage_link
    link_to '返回首页',pin_url_for('pin-user-auth')
  end

  def preview_email(method)
    render :partial=>"mailer/#{method}",:locals=>{:preview=>true,:sender=>current_user}
  end

  def index_tabs_link_to(options = {}, html_options = {}, &block)
    klass = html_options[:class]
    klass = [klass,'selected']*' '
    return link_to(options, html_options.merge(:class=>klass), &block) if current_page?(options)
    link_to(options, html_options, &block)
  end

end
