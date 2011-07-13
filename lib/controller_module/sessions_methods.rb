module SessionsMethods
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
