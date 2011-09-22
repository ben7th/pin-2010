class ConnectUsersController < ApplicationController
  def send_tsina_status
    SendTsinaStatusQueueWorker.async_send_tsina_status(:user_id=>current_user.id,:content=>params[:content])
    render :status=>200,:text=>"success"
  end

  def send_tsina_mindmap
    mindmap = Mindmap.find_by_id(params[:mindmap_id])
    return(reder :status=>500,:text=>"导图不存在") if mindmap.blank?
    image_path = MindmapImageCache.new(mindmap).thumb_500_img_path
    SendTsinaStatusQueueWorker.async_send_tsina_status({:user_id=>current_user.id,:content=>params[:content],:image_path=>image_path})
    render :status=>200,:text=>"success"
  end

  def send_tsina_status_with_logo
    logo_image_path = "#{RAILS_ROOT}/public/images/icons_account/mindpin_logo.png"
    SendTsinaStatusQueueWorker.async_send_tsina_status(:user_id=>current_user.id,:content=>params[:content],:image_path=>logo_image_path)
    render :status=>200,:text=>"success"
  end

  private
  def opener_window_redirect_to(url)
    render :text=>%`
      <script>
        window.opener.location = "#{url}";
        window.close();
      </script>
    `
  end

  def clear_session_connect_info
    session[:renren_atoken] = nil
    session[:tsina_atoken] = nil
    session[:tsina_asecret] = nil
    session[:connect_confirm] = nil
  end

  def set_tsina_token_to_session_by_request_token_of_session
    request_token = session[:request_token]
    session[:request_token] = nil
    access_token = Tsina.get_access_token_by_request_token_and_oauth_verifier(request_token,params[:oauth_verifier])
    session[:tsina_atoken] = access_token.token
    session[:tsina_asecret] = access_token.secret
  end

  include BindTsinaControllerMethods
  include ConnectTsinaControllerMethods
end