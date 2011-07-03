module SessionsMethods
  def self.included(base)
    # 登录表单不进行csrf校验
    base.skip_before_filter :verify_authenticity_token
  end

  # 登录
  def new
    if logged_in?
      return redirect_back_or_default(root_url)
    end

    render :layout=>'anonymous',:template=>'index/login'
  end

  # 创建session
  def create
    self.current_user = User.authenticate(params[:email],params[:password])

    if logged_in?
      after_logged_in()
      return redirect_back_or_default(root_url)
    else
      flash[:error]="邮箱/密码不正确"
      redirect_to "/"
    end
  end

  # 登出
  def destroy
    user = current_user

    if user
      reset_session_with_online_key()
      # 登出时销毁cookies令牌
      destroy_remember_me_cookie_token()
      destroy_online_record(user)
    end
    
    redirect_to root_url
  end


  def after_logged_in
    # 清除当前用户的“未登陆访问者”记录
    clear_anonymous_online_key()
    # 把在线状态刷新的计时器置空，使得状态马上可以刷新
    ready_for_online_records_refresh()
    # 登录时生成cookies令牌
    create_remember_me_cookie_token()
    # 设置当前用户的登录时间
    update_last_login_time()
  end

  def clear_anonymous_online_key
    OnlineRecord.clear_online_key(session[:online_key])
  end

  def ready_for_online_records_refresh
    session[:last_time_online_refresh]=nil
  end

  def create_remember_me_cookie_token
    if params[:remember_me]
      cookies[:token]=current_user.create_cookies_token(30)
    end
  end

  def update_last_login_time()
    current_user.update_attributes(:last_login_time=>Time.now)
  end

  def reset_session_with_online_key
    online_key=session[:online_key]
    reset_session
    session[:online_key]=online_key
  end

  def destroy_remember_me_cookie_token
    cookies[:token] = {
      :value=>nil,
      :expires=>0.days.from_now,
      :domain=>ActionController::Base.session_options[:domain]
    }
  end

  def destroy_online_record(user)
    if user.online_record
      user.online_record.destroy
    end
  end
end
