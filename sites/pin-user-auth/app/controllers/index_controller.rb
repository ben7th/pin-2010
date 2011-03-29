class IndexController < ApplicationController
  def index
    # 未登录
    if !logged_in?
      return render :template=>'auth/index',:layout=>'auth'
    end
    
    # 登录
    @feeds = current_user.in_feeds.paginate(:per_page=>10,:page=>params[:page]||1)
    current_user.refresh_newest_feed_id
  end

  #----临时调试用----
    def updating
     redirect_to '/updating.html',:status=>301
    end

    def dev
      render_ui do |ui|
        ui.fbox :show,:title=>'bucuo',:partial=>'index/dev'
      end
    end
end