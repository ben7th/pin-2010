class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if !logged_in?
      @feeds = Feed.recent_hot(:per_page=>20,:page=>params[:page]||1,:order=>'id desc')
      return render(:template=>'auth/no_auth_index')
    end

    # 登录后

    # 主题协作
    if current_user.use_feed?
      redirect_to '/feeds',:status=>301
      return
    end

    # 思维导图
    if current_user.use_mindmap?
      redirect_to '/mindmaps',:status=>301
      return
    end

    # 选择用途
    redirect_to '/account/usage_setting',:status=>301
  end

  def in_feeds_more
    @feeds = current_user.in_feeds_more(params[:count],params[:last_vector])

    render :partial=>'feeds/lists/feeds_stat',:locals=>{:feeds=>@feeds}
  end

  def feedback
    
  end
end