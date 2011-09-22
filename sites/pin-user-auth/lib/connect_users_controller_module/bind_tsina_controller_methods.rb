module BindTsinaControllerMethods
  def bind_tsina
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.bind_authorize_url
  end

  def bind_tsina_callback
    # TODO 此处会因为浏览器缓存的一些问题导致崩溃
    # 建议存放在服务器缓存中
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
      return redirect_to "/account/bind_tsina"
    end
    render :layout=>"account"
  end

  def update_bind_tsina_info
    cu = current_user.tsina_connect_user
    cu.update_account_detail
    result = @template.render :partial=>"/account/bind_parts/binded_tsina_account_info"
    render :text=>result
  end

end
