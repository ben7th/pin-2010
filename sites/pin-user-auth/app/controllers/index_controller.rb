class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if logged_in? && current_user.is_v2_activation_user?
      @feeds = current_user.in_feeds.paginate(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
      @collections = current_user.in_collections
      if is_android_client?
        return render :json=>@feeds
      else
        return render :template=>'index/index_page'
      end
    end

    # 如果还没有登录，渲染登录页
    render :layout=>'anonymous',:template=>'index/services'
  end

  def in_feeds_more
    @feeds = current_user.in_feeds_more(params[:count],params[:last_vector])

    render :partial=>'feeds/lists/feeds_stat',:locals=>{:feeds=>@feeds}
  end

  def feedback
    
  end

end