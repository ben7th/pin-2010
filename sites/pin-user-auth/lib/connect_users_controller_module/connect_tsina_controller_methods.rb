module ConnectTsinaControllerMethods
  include SessionsMethods

  # 清除session中所有和新浪微博授权相关信息
  def clear_session_connect_info
    session[:renren_atoken]   = nil
    session[:tsina_atoken]    = nil
    session[:tsina_asecret]   = nil
    session[:connect_confirm] = nil
  end

  # 根据session中保存的 :request_token 计算 atoken 和 asccret 并保存在session里
  def set_tsina_token_to_session_by_request_token_of_session
    request_token = session[:request_token]
    session[:request_token] = nil
    
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token, params[:oauth_verifier])
    session[:tsina_atoken]  = access_token.token
    session[:tsina_asecret] = access_token.secret
  end

  # 从session中获取tsina_user_info 和 connect_user对象
  def get_connect_user_from_session
    atoken  = session[:tsina_atoken]
    asecret = session[:tsina_asecret]

    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken, asecret)
    connect_id = tsina_user_info["connect_id"]

    connect_user = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)

    return [tsina_user_info, connect_user]
  end

  # 处理连接新浪微博授权后的callback信息，并设置登录用户，重定向等
  def deal_tsina_callback(redirect_url)
    # 在session里设置一些oauth相关的数据

    # TODO 此处会因为浏览器缓存的一些问题导致逻辑不正确
    # 建议日后存放在服务器缓存中

    set_tsina_token_to_session_by_request_token_of_session
    tsina_user_info, connect_user = get_connect_user_from_session

    if !connect_user.blank?
      # 这种情况下，
      # 网站里目前存在对应该新浪微博账号的 mindpin 账号

      # 更新对应账号的新浪微博meta信息
      connect_user.update_tsina_info(tsina_user_info, session[:tsina_atoken], session[:tsina_asecret])

      # 以该mindpin账号登录
      user = connect_user.user
      self.current_user = user
      after_logged_in()

      # 如果是普通账号，重定向到参数的指定页，完成这次登录
      return redirect_to redirect_url
    end

    # 这种情况下
    # 网站里不存在对应该新浪微博账号的 mindpin 账号，
    # 用户是首次使用该新浪微博账号访问 mindpin，此时，重定向到confirm页面
    # 让其选择关联方式： 新建账号 / 使用原有mindpin账号
    _redirect_connect_tsina_confirm
  end

  def _redirect_connect_tsina_confirm
    return redirect_to "/account/tsina_signup"
  end

  # 完成绑定，持久化数据操作
  def do_connect_user_bind_tsina(user, tsina_user_info)
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]

    connect_id = tsina_user_info["connect_id"]

    ConnectUser.bind_tsina_connect_user(connect_id, user, tsina_user_info, atoken, asecret)
  end
end
