module TsinaControllerMethods
  def connect_tsina
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.authorize_url
  end

  def connect_tsina_callback
    set_tsina_token_to_session_by_request_token_of_session
    session[:connect_confirm] = "tsina"
    opener_window_redirect_to(pin_url_for("pin-user-auth","/connect_confirm"))
  end

  def bind_tsina
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.bind_authorize_url
  end

  def bind_tsina_callback
    request_token = session[:request_token]
    session[:request_token] = nil
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token,params[:oauth_verifier])
    atoken,asecret = access_token.token,access_token.secret
    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)

    connect_id = tsina_user_info["connect_id"]
    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)
    if cu.blank?
      ConnectUser.bind_tsina_connect_user(
        connect_id,current_user,tsina_user_info,
        access_token.token,access_token.secret)
      result_url = pin_url_for("pin-user-auth","/account/bind_tsina?r=success")
    else
      session[:connect_user_id] = cu.id
      result_url = pin_url_for("pin-user-auth","/bind_other_site/tsina_failure")
    end
    session[:request_token] = nil
    opener_window_redirect_to result_url
  end

  def bind_tsina_failure
    @connect_user = ConnectUser.find_by_id(session[:connect_user_id])
    session[:connect_user_id] = nil
    if @connect_user.nil?
      redirect_to "/account/bind_tsina"
    end
  end

  def update_bind_tsina_info
    cu = current_user.tsina_connect_user
    cu.update_account_detail
    result = @template.render :partial=>"/account/bind_parts/binded_tsina_account_info"
    render :text=>result
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
      return redirect_to "/"
    end
    render :template=>"/connect_users/connect_tsina_confirm"
  end

  def create_tsina_quick_connect_account
    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]
    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]
    user_name = tsina_user_info["user_name"]
    connect_user = ConnectUser.create_tsina_connect_user(
      connect_id,user_name,tsina_user_info,
      atoken,asecret)
    self.current_user = connect_user.user
    clear_session_connect_info
    redirect_to "/"
  end

  def tsina_bind_mindpin_typical_account
    user = User.authenticate(params[:email],params[:password])

    # 没有匹配到用户
    if user.blank?
      flash[:error] = "邮箱或者密码错误"
      return redirect_to :action=>:connect_confirm,:params=>{:r=>"error"}
    end
    if !user.tsina_connect_user.blank?
      flash[:error] = "指定的账号已经绑定过新浪微博啦"
      return redirect_to :action=>:connect_confirm,:params=>{:r=>"error"}
    end

    atoken = session[:tsina_atoken]
    asecret = session[:tsina_asecret]
    @tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = @tsina_user_info["connect_id"]
    connect_user = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)

    if !connect_user.blank?
      return render_status_page(503,"不允许的操作。尝试对同一组账号进行反复绑定。")
    end

    ConnectUser.bind_tsina_connect_user(
      connect_id,user,@tsina_user_info,atoken,asecret)
    self.current_user = user
    
    clear_session_connect_info
    redirect_to "/account/bind_tsina"
  end

  def set_tsina_token_to_session_by_request_token_of_session
    request_token = session[:request_token]
    session[:request_token] = nil
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token,params[:oauth_verifier])
    session[:tsina_atoken] = access_token.token
    session[:tsina_asecret] = access_token.secret
  end

end
