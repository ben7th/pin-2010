module RenrenControllerMethods
  def connect_renren
    redirect_to RenRen.new.authorize_url
  end

  def connect_renren_callback
    renren = RenRen.new
    access_token = renren.get_access_token(params[:code])
    session[:renren_atoken] = access_token
    session[:connect_success] = "renren"
    opener_window_redirect_to(pin_url_for("pin-user-auth","/connect_success"))
  end

  def bind_renren
    redirect_to RenRen.new.bind_authorize_url
  end

  def bind_renren_callback
    access_token = RenRen.new.get_bind_access_token(params[:code])

    renren_user_info = RenRen.new.get_user_info(access_token)
    connect_id = renren_user_info["connect_id"]
    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::RENREN_CONNECT_TYPE,connect_id)
    if cu.blank?
      ConnectUser.bind_renren_connect_user(
        connect_id,current_user,renren_user_info,access_token)
      result_url = pin_url_for("pin-user-auth","/account/bind_renren?r=success")
    else
      session[:connect_user_id] = cu.id
      result_url = pin_url_for("pin-user-auth","/bind_other_site/renren_failure")
    end
    session[:request_token] = nil
    opener_window_redirect_to result_url
  end

  def bind_renren_failure
    @connect_user = ConnectUser.find_by_id(session[:connect_user_id])
    session[:connect_user_id] = nil
    if @connect_user.nil?
      redirect_to "/account/bind_renren"
    end
  end

  def update_bind_renren_info
    cu = current_user.renren_connect_user
    cu.update_account_detail
    result = @template.render :partial=>"/account/bind_parts/binded_renren_account_info"
    render :text=>result
  end

  def connect_renren_success
    atoken = session[:renren_atoken]
    @renren_user_info = RenRen.new.get_user_info(atoken)
    connect_id = @renren_user_info["connect_id"]
    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::RENREN_CONNECT_TYPE,connect_id)
    if !cu.blank?
      cu.update_renren_info(@renren_user_info,atoken)
      self.current_user = cu.user
      return redirect_to "/"
    end
    render :template=>"/connect_users/connect_renren_success"
  end

  def create_renren_quick_connect_account
    atoken = session[:renren_atoken]
    @renren_user_info = RenRen.new.get_user_info(atoken)
    connect_id = @renren_user_info["connect_id"]
    user_name = @renren_user_info["user_name"]
    connect_user = ConnectUser.create_renren_connect_user(
      connect_id,user_name,@renren_user_info,
      atoken)
    self.current_user = connect_user.user
    clear_session_connect_info
    redirect_to "/"
  end

  def renren_bind_mindpin_typical_account
    user = User.authenticate(params[:email],params[:password])
    if user.blank?
      flash[:error] = "邮箱或者密码错误"
      return redirect_to :action=>:connect_success
    end
    atoken = session[:renren_atoken]
    @renren_user_info = RenRen.new.get_user_info(atoken)
    connect_id = @renren_user_info["connect_id"]
    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::RENREN_CONNECT_TYPE,connect_id)
    return render_status_page(503,"非法操作") if !cu.blank?
    if !user.renren_connect_user.blank?
      flash[:error] = "这个 mindpin账号 已经绑定过其他的人人账号"
      return redirect_to :action=>:connect_success
    end
    ConnectUser.bind_renren_connect_user(
      connect_id,user,@renren_user_info,atoken)
    self.current_user = user
    clear_session_connect_info
    redirect_to "/"
  end
end
