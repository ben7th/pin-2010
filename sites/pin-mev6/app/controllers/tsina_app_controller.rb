class TsinaAppController < ApplicationController
  include MindmapRightsHelper
  before_filter :check_current_user,:only=>[:mindmaps,:create_mindmap,:edit]
  def check_current_user
    if !logged_in? || !current_user.has_binded_sina?
      redirect_to "/tsina_app"
    end
  end

  def index
    render :layout=>"tsina_app"
  end

  def connect
    tsina = Tsina.new
    session[:request_token] = tsina.request_token
    redirect_to tsina.mindmap_app_authorize_url
  end

  def connect_callback
    _connect_callback_set_current_user
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
    if has_edit_rights?(@mindmap,current_user)
      return render :template=>"/mindmap_editor/tsina_app_editor",:layout=>"mindmap"
    end
    render :text=>"没有编辑权限",:status=>401
  end

  private
  def _connect_callback_set_current_user
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


    if logged_in?
      tsina_connect_user = current_user.tsina_connect_user

      if cu.blank? && !tsina_connect_user
        ConnectUser.bind_tsina_connect_user(
          connect_id,current_user,tsina_user_info,
          atoken,asecret)
      elsif cu.blank? && !!tsina_connect_user
        connect_user = ConnectUser.create_tsina_connect_user(
          connect_id,user_name,tsina_user_info,
          atoken,asecret)
        self.current_user = connect_user.user
      elsif !cu.blank? && (cu == tsina_connect_user)
        cu.update_tsina_info(tsina_user_info,atoken,asecret)
      elsif !cu.blank? && (cu != tsina_connect_user)
        cu.update_tsina_info(tsina_user_info,atoken,asecret)
        self.current_user = cu.user
      end

    else
        if cu.blank?
          connect_user = ConnectUser.create_tsina_connect_user(
            connect_id,user_name,tsina_user_info,
            atoken,asecret)
          self.current_user = connect_user.user
        else
          cu.update_tsina_info(tsina_user_info,atoken,asecret)
          self.current_user = cu.user
        end
    end
  end

end