class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if !logged_in?
      return render(:template=>'auth/index')
    end

    # 登录后，显示登录后首页
    @feeds = current_user.in_feeds.paginate(:per_page=>10,:page=>params[:page]||1)
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