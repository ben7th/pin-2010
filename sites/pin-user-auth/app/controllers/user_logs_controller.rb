class UserLogsController < ApplicationController
  before_filter :login_required,:except=>[:index,:newest]
  def index
    return _index_login unless current_user.blank?

    newest
  end

  def _index_login
    case cookies[:menu_user_logs_tab]
    when "friends" then friends
    when "newest" then newest
    else
      friends
    end
  end

  def friends
    set_cookies_menu_user_logs_tab "friends"
    @userlogs = current_user.inbox_logs.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"/user_logs/friends"
  end

  def newest
    set_cookies_menu_user_logs_tab "newest"
    @userlogs = UserLog.paginate(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
    render :template=>"/user_logs/newest"
  end

  private
  def set_cookies_menu_user_logs_tab(name)
    cookies[:menu_user_logs_tab] = name
  end


end
