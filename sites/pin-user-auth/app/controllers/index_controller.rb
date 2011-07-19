class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if logged_in? && current_user.is_v2_activation_user?
      return render :text=>'临时首页'
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