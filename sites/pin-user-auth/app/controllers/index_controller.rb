class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if logged_in? && current_user.is_v2_activation_user?
      @feeds = current_user.in_feeds.paginate(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
      @collections = current_user.in_collections
      if is_android_client?
        return render :json=>@feeds
      else
        return render :template=>'index/index_page',:layout=>'collection'
      end
    end

    # 如果还没有登录，渲染登录页
    render :layout=>'anonymous',:template=>'index/services'
  end
end