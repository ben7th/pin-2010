class UsersController < ApplicationController
  before_filter :login_required,:only => [
    :edit,:update,
    :fans,:followings
  ]

  def show
    @user = User.find(params[:id])
    @feeds = @user.user_timeline(:count=>40,:page=>params[:page] || 1)

    if request.xhr?
      return render :partial=>'feeds/parts/grid',:locals=>{:feeds=>@feeds}
    end
  end

  def favs
    @user = User.find(params[:id])
    @feeds = @user.fav_feeds_limit(20)
  end

  def index
    return _index_login unless current_user.blank?

    reputation_rank
  end

  def _index_login
    case cookies[:menu_users_tab]
    when "fans" then fans
    when "followings" then followings
    when "reputation_rank" then reputation_rank
    when "feeds_rank" then feeds_rank
    when "viewpoints_rank" then viewpoints_rank
    else
      followings
    end
  end

  def fans
    set_cookies_menu_users_tab "fans"
    @fans = current_user.fans.paginate(:per_page=>15,:page=>params[:page]||1)
    render :template=>"users/fans"
  end

  def followings
    set_cookies_menu_users_tab "followings"
    @followings = current_user.followings.paginate(:per_page=>15,:page=>params[:page]||1)
    render :template=>"users/followings"
  end

  def reputation_rank
    set_cookies_menu_users_tab "reputation_rank"
    @users = User.reputation_rank.paginate(:per_page=>100,:page=>params[:page]||1)
    render :template=>"users/reputation_rank"
  end

  def feeds_rank
    set_cookies_menu_users_tab "feeds_rank"
    @users = User.feeds_rank.paginate(:per_page=>100,:page=>params[:page]||1)
    render :template=>"users/feeds_rank"
  end

  def viewpoints_rank
    set_cookies_menu_users_tab "viewpoints_rank"
    @users = User.viewpoints_rank.paginate(:per_page=>100,:page=>params[:page]||1)
    render :template=>"users/viewpoints_rank"
  end

  private
  def is_current_user?
    session[:user_id].to_s==params[:id]
  end

  def set_cookies_menu_users_tab(name)
    cookies[:menu_users_tab] = name
  end

end
