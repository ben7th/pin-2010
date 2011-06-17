class NoticesController < ApplicationController
  before_filter :login_required
  def common
    set_cookies_menu_notices_tab "common"
    utp = UserTipProxy.new(current_user)
    @tips = utp.tips
    render :template=>"notices/common"
  end

  def invites
    set_cookies_menu_notices_tab "invites"
    @feed_invites = current_user.feed_invites.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"notices/invites"
  end

  def index
    case cookies[:menu_notices_tab]
    when "common" then common
    when "invites" then invites
    else
      common
    end
  end

  private
  def set_cookies_menu_notices_tab(name)
    cookies[:menu_notices_tab] = name
  end
end
