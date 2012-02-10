class Account::TsinaController < ApplicationController
  include ConnectTsinaControllerMethods

  def index
    render :layout=>'account'
  end

  def connect
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.account_connect_authorize_url
  end

  def callback
    set_tsina_token_to_session_by_request_token_of_session
    tsina_user_info, connect_user = get_connect_user_from_session
    
    if connect_user.blank?
      # 如果没有绑定过，绑定当前用户，并返回设置页
      do_connect_user_bind_tsina(current_user, tsina_user_info)
      redirect_to "/account/tsina?r=success"
    else
      # 如果已经绑定过了，则无法绑定，显示错误页面

      session[:connect_failure_user_id] = connect_user.id
      redirect_to "/account/tsina/connect_failure"
    end
  end

  def connect_failure
    @connected_user = ConnectUser.find_by_id(session[:connect_failure_user_id])
    return redirect_to "/account/tsina" if @connected_user.nil?
    render :layout=>"account"
  end

  def update_info
    cu = current_user.tsina_connect_user
    cu.update_account_detail
    result = view_context.render :partial=>"/account/bind_parts/binded_tsina_account_info"
    render :text=>result
  end

  def disconnect
    if !current_user.is_mindpin_typical_account?
      return render_status_page(503, "当前账号信息不完整，无法解除新浪微博账号关联，否则将无法登录")
    end
    current_user.unbind_tsina_account
    redirect_to "/account/tsina"
  end
  
end