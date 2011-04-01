class ConnectUsersController < ApplicationController
  def index
  end

  def send_tsina_status
    SendTsinaStatusQueue.new.add_task(:user_id=>current_user.id,:content=>params[:content])
    render :status=>200,:text=>"success"
  end

  def send_tsina_mindmap
    mindmap = Mindmap.find_by_id(params[:mindmap_id])
    return(reder :status=>500,:text=>"导图不存在") if mindmap.blank?
    image_path = MindmapImageCache.new(mindmap).get_img_path_by("500x500")
    SendTsinaStatusQueue.new.add_task({:user_id=>current_user.id,:content=>params[:content],:image_path=>image_path})
    render :status=>200,:text=>"success"
  end

  def send_tsina_status_with_logo
    logo_image_path = "#{RAILS_ROOT}/public/images/icons_account/mindpin_logo.png"
    SendTsinaStatusQueue.new.add_task(:user_id=>current_user.id,:content=>params[:content],:image_path=>logo_image_path)
    render :status=>200,:text=>"success"
  end

  def connect_confirm
    case session[:connect_confirm]
    when "tsina"
      connect_tsina_confirm
    when "renren"
      connect_renren_confirm
    else
      raise "未定义的连接类型"
    end
  end

  def create_quick_connect_account
    case session[:connect_confirm]
    when "tsina"
      create_tsina_quick_connect_account
    when "renren"
      create_renren_quick_connect_account
    else
      raise "未定义的连接类型"
    end
  end

  def bind_mindpin_typical_account
    case session[:connect_confirm]
    when "tsina"
      tsina_bind_mindpin_typical_account
    when "renren"
      renren_bind_mindpin_typical_account
    else
      raise "未定义的连接类型"
    end
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

  include RenrenControllerMethods
  include TsinaControllerMethods
end