class UsersController < ApplicationController
  before_filter :login_required,:only => [:edit,:update,
    :fans,:followings
  ]

  include SessionsMethods

  # forgot_password_form forgot_password reset_password change_password
  include ResetPasswordMethods

  def new
    online_key=session[:online_key]
    reset_session
    session[:online_key]=online_key
    @user=User.new
    render :template=>'auth/signup'
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # flash[:success]="注册成功，请使用新帐号登陆"
      login_after_create(@user)
    else
      flash.now[:error]=get_flash_error(@user)
      render :template=>'auth/signup'
    end
  end

  def do_reg
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # 邀请注册成功后，互相加为联系人
      InvitationEmail.new(params[:invition_sender_email],@user.email).done
      login_after_create(@user)
    else
      flash.now[:error]=get_flash_error(@user)
      render :action=>:show
    end
  end

  def login_after_create(user)
    self.current_user=user
    after_logged_in()
    redirect_to '/'
  end

  def cooperate
    set_cellhead_path('/index/cellhead')
    @user = User.find(params[:id])
    @cooperate_edit_mindmaps = @user.cooperate_edit_mindmaps
    @cooperate_view_mindmaps = @user.cooperate_view_mindmaps
  end

  def show
    @user = User.find(params[:id])

    if !logged_in?
      redirect_to "/users/#{@user.id}/logs",:status=>301
      return
    end

    if current_user.use_feed?
      redirect_to "/users/#{@user.id}/logs",:status=>301
      return
    end

    if current_user.use_mindmap?
      redirect_to "/mindmaps/users/#{@user.id}",:status=>301
      return
    end

    redirect_to '/account/usage_setting',:status=>301
  end

  def logs
    @user = User.find(params[:id])
    render :template=>'users/homepage'
  end

  def feeds
    @user = User.find(params[:id])
    @feeds = @user.out_feeds_limit(20)
  end

  def viewpoints
    @user = User.find(params[:id])
    @viewpoints = @user.viewpoints_limit(20)
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
