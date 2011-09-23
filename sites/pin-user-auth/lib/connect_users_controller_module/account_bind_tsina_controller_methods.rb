module AccountBindTsinaControllerMethods
  def account_bind
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.bind_authorize_url
  end

  def account_bind_callback
    # TODO 此处会因为浏览器缓存的一些问题导致崩溃
    # 建议存放在服务器缓存中
    set_tsina_token_to_session_by_request_token_of_session
    tsina_user_info, connect_user = get_connect_user_from_session
    connect_id = tsina_user_info["connect_id"]
    if connect_user.blank?
      # 如果没有绑定过，绑定当前用户，并返回设置页
      ConnectUser.bind_tsina_connect_user(
        connect_id,current_user,tsina_user_info,
        session[:tsina_atoken],session[:tsina_asecret])
      result_url = pin_url_for("pin-user-auth","/account/bind_tsina?r=success")
    else
      session[:connect_user_id] = connect_user.id
      result_url = pin_url_for("pin-user-auth","/connect_tsina/account_bind_failure")
    end
    

    session[:request_token] = nil
    redirect_to result_url
  end

  #绑定失败，显示失败信息
  def account_bind_failure
    @connected_user = ConnectUser.find_by_id(session[:connect_user_id])
    if @connected_user.nil?
      return redirect_to "/account/bind_tsina"
    end
    render :layout=>"account"
  end

  def account_bind_update_info
    cu = current_user.tsina_connect_user
    cu.update_account_detail
    result = @template.render :partial=>"/account/bind_parts/binded_tsina_account_info"
    render :text=>result
  end

  def account_bind_unbind
    if !current_user.is_mindpin_typical_account?
      return render_status_page(503,"非法操作")
    end
    current_user.unbind_tsina_account
    redirect_to "/account/bind_tsina"
  end

end
