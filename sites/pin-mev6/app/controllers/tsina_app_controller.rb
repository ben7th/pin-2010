class TsinaAppController < ApplicationController
  before_filter :check_current_user,:only=>[:mindmaps,:create_mindmap]
  def check_current_user
    if !logged_in? || !current_user.has_binded_sina?
      redirect_to "/tsina_app"
    end
  end

  def index
    render :layout=>"tsina_app"
  end

  def connect
    #1 登录了快速连接账号
    #2 登录了 绑定 tsina 的 mindpin 账号
    if logged_in? && current_user.has_binded_sina?
      return redirect_to "/tsina_app/mindmaps"
    end
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.mindmap_app_authorize_url
  end

  def connect_callback
    #1 没有 登录任何账号
    #2 登录了 没有绑定 tsina 的 mindpin 账号
    request_token = session[:request_token]
    session[:request_token] = nil
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token,params[:oauth_verifier])
    atoken = access_token.token
    asecret = access_token.secret
    tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
    connect_id = tsina_user_info["connect_id"]
    user_name = tsina_user_info["user_name"]

    cu = ConnectUser.find_by_connect_type_and_connect_id(
      ConnectUser::TSINA_CONNECT_TYPE,connect_id)

    if logged_in? && cu.blank?
      ConnectUser.bind_tsina_connect_user(
        connect_id,current_user,tsina_user_info,
        atoken,asecret)
    elsif !logged_in? && cu.blank?
      connect_user = ConnectUser.create_tsina_connect_user(
        connect_id,user_name,tsina_user_info,
        atoken,asecret)
      self.current_user = connect_user.user
    else
      cu.update_tsina_info(tsina_user_info,atoken,asecret)
      self.current_user = cu.user
    end

    redirect_to "/tsina_app/mindmaps"
  end
  
  def mindmaps
    render :layout=>"tsina_app"
  end

  def create_mindmap
    @mindmap = Mindmap.create_by_params(current_user,params[:mindmap])
    unless @mindmap.id.blank?
      return redirect_to "/tsina_app/mindmaps/#{@mindmap.id}/edit"
    end
    redirect_to "/tsina_app/mindmaps"
  end

  def edit
    @mindmap = Mindmap.find(params[:id])
    render :template=>"/mindmap_editor/tsina_app_editor",:layout=>"mindmap"
  end

end