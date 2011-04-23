class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if !logged_in?
      @feeds = Feed.paginate(:per_page=>20,:page=>params[:page]||1,:order=>'id desc')
      return render(:template=>'auth/no_auth_index')
    end

    # 登录后，显示登录后首页
    @feeds = current_user.in_feeds.paginate(:per_page=>10,:page=>params[:page]||1)
  end
end