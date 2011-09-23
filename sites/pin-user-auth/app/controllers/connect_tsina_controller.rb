class ConnectTsinaController < ApplicationController
  include SessionsMethods
  include AccountBindTsinaControllerMethods

  # 前置过滤器，index和callback两个action必须在不登录的状态下访问
  before_filter :must_be_not_login,:only=>[:index,:callback]
  def must_be_not_login
    if logged_in?
      return render_status_page(401,"你已经登录过了")
    end
  end

  # 首页上点使用新浪微博连接按钮时访问此action
  def index
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.authorize_url
  end

  # 新浪微博授权后，会访问此地址
  def callback
    # 在session里设置一些oauth相关的数据
    set_tsina_token_to_session_by_request_token_of_session

    tsina_user_info, connect_user = get_connect_user_from_session

    if !connect_user.blank?
      # 网站里目前存在对应账号

      # 更新对应账号的新浪微博meta信息
      connect_user.update_tsina_info(tsina_user_info,session[:tsina_atoken], session[:tsina_asecret])

      #登录
      user = connect_user.user
      self.current_user = user 
      after_logged_in()

      # 如果是快速连接账号，重定向到complete_account_info
      return redirect_complete_account_info if user.is_quick_connect_account?
      # 如果是普通账号，重定向到子站首页，根据params[:service]
      return redirect_root_by_service
    end

    # 网站里不存在对应账号，重定向到confirm页面
    redirect_connect_tsina_confirm
  end
  
  def confirm
    @tsina_user_info, connect_user = get_connect_user_from_session
    
    if !connect_user.blank?
      render_status_page(500,"新浪微博连接与用户数据不匹配")
    end

    # else
    # 没有关联过，新建账号或关联账号
    # confirm
  end

  # 要求补充用户信息
  def complete_account_info
    render :layout=>'account'
  end

  # 补充用户信息，提交
  def do_complete_account_info
    valid_user = User.new(params[:user])
    valid_user.name = randstr
    unless valid_user.valid?
      flash[:error] = get_flash_error(valid_user)
      return redirect_connect_tsina_confirm
    end

    current_user.email = params[:user][:email]
    current_user.password = params[:user][:password]
    current_user.password_confirmation = params[:user][:password_confirmation]
    
    if current_user.save
      return redirect_root_by_service
    end
    
    flash[:error] = get_flash_error(current_user)
    redirect_connect_tsina_confirm
  end

  # 使用原有账号账号绑定新浪微博
  def bind
    mindpin_user = User.authenticate(params[:email],params[:password])
    
    if mindpin_user.blank?
      flash[:error] = "邮箱/密码错误"
      return redirect_connect_tsina_confirm
    end
    unless mindpin_user.tsina_connect_user.blank?
      flash[:error] = "这个Mindpin账号已经绑定了其它的新浪微博账号"
      return redirect_connect_tsina_confirm
    end

    bind_and_login_from_session(mindpin_user)
    redirect_root_by_service
  end

  # 注册新账号并绑定新浪微博
  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_remember_me_cookie_token
    mindpin_user = User.new(params[:user])

    unless mindpin_user.save
      flash[:error] = get_flash_error(mindpin_user)
      flash[:mode] = 2
      return redirect_connect_tsina_confirm
    end

    bind_and_login_from_session(mindpin_user)
    redirect_root_by_service
  end

  #------ 以下为私有方法 --------
  private
  def clear_session_connect_info
    session[:renren_atoken] = nil
    session[:tsina_atoken] = nil
    session[:tsina_asecret] = nil
    session[:connect_confirm] = nil
  end

  def set_tsina_token_to_session_by_request_token_of_session
    request_token = session[:request_token]
    session[:request_token] = nil
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token,params[:oauth_verifier])
    session[:tsina_atoken] = access_token.token
    session[:tsina_asecret] = access_token.secret
  end

  def redirect_connect_tsina_confirm
    if params[:service] == "tu"
      return redirect_to "/connect_tsina/confirm?service=tu"
    else
      return redirect_to "/connect_tsina/confirm"
    end
  end

  def redirect_complete_account_info
    if params[:service] == "tu"
      return redirect_to "/connect_tsina/complete_account_info?service=tu"
    else
      return redirect_to "/connect_tsina/complete_account_info"
    end
  end

  def get_connect_user_from_session
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]

    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]

    connect_user = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)

    return [tsina_user_info, connect_user]
  end

  def bind_and_login_from_session(mindpin_user)
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]

    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]

    ConnectUser.bind_tsina_connect_user(
      connect_id,mindpin_user,tsina_user_info,
      atoken,asecret)
    
    self.current_user = mindpin_user #登录
    after_logged_in()
  end

  def redirect_root_by_service
    if params[:service] == "tu"
      redirect_to(pin_url_for("pin-daotu"))
    else
      redirect_to(root_url)
    end
  end
  
end