module ConnectTsinaControllerMethods
  def self.included(base)
    base.before_filter :must_no_logged_in,:only=>[:connect_user,:connect_tsina_callback]
    base.send :include, SessionsMethods
  end
  def must_no_logged_in
    if logged_in?
      return render_status_page(401,"你已经登录过了")
    end
  end

  def connect_tsina
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.authorize_url
  end

  def connect_tsina_callback
    set_tsina_token_to_session_by_request_token_of_session
    redirect_connect_tsina_confirm
  end

  def connect_tsina_confirm
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]
    @tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = @tsina_user_info["connect_id"]
    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)
    if !cu.blank?
      cu.update_tsina_info(@tsina_user_info,atoken,asecret)
      self.current_user = cu.user
      if cu.user.is_quick_connect_account?
        return redirect_complete_account_info
      end
      return redirect_root_by_service
    end

    # else
    # 没有关联过，新建账号或关联账号
  end

  def complete_account_info
  end

  def do_complete_account_info
    email = params[:user][:email]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    error_message = []
    error_message.push("邮箱地址不能为空")  if email.blank?
    begin
      error_message.push("该邮箱已经被使用了") if !email.blank? && EmailActor.new(email).signed_in?
    rescue EmailActor::EmailFormatError=>ex
      error_message.push(ex.message)
    end
    error_message.push("密码不能为空") if password.blank?
    if !error_message.blank?
      flash[:error] = error_message.first
      return redirect_connect_tsina_confirm
    end
    current_user.email = email
    current_user.password = password
    current_user.password_confirmation = password_confirmation
    if current_user.save
      return redirect_root_by_service
    end
    flash[:error] = get_flash_error(current_user)
    redirect_connect_tsina_confirm
  end

  def bind
    bind_user = User.authenticate(params[:email],params[:password])
    if bind_user.blank?
      flash[:error] = "邮箱/密码错误"
      return redirect_connect_tsina_confirm
    end
    unless bind_user.tsina_connect_user.blank?
      flash[:error] = "这个Mindpin账号已经绑定了其它的新浪微博账号"
      return redirect_connect_tsina_confirm
    end

    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]
    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]
    ConnectUser.bind_tsina_connect_user(
      connect_id,bind_user,tsina_user_info,
      atoken,asecret)
    self.current_user = bind_user
    redirect_root_by_service
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_remember_me_cookie_token
    @user=User.new(params[:user])
    unless @user.save
      flash[:error] = get_flash_error(@user)
      flash[:mode] = 2
      return redirect_connect_tsina_confirm
    end
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]
    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]
    ConnectUser.bind_tsina_connect_user(
      connect_id,@user,tsina_user_info,
      atoken,asecret)
    self.current_user = @user
    after_logged_in()
    redirect_root_by_service
  end

  def redirect_complete_account_info
    if params[:service] == "tu"
      return redirect_to "/connect_tsina/complete_account_info?service=tu"
    else
      return redirect_to "/connect_tsina/complete_account_info"
    end
  end

  def redirect_connect_tsina_confirm
    if params[:service] == "tu"
      return redirect_to "/connect_tsina_confirm?service=tu"
    else
      return redirect_to "/connect_tsina_confirm"
    end
  end

  def redirect_root_by_service
    if params[:service] == "tu"
      redirect_to(pin_url_for("pin-daotu"))
    else
      redirect_to(root_url)
    end
  end
end
