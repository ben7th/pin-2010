class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if !logged_in?
      @feeds = Feed.recent_hot(:per_page=>20,:page=>params[:page]||1,:order=>'id desc')
      return render(:template=>'auth/no_auth_index')
    end

    @feeds = current_user.in_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def in_feeds_more
    @feeds = current_user.in_feeds_more(params[:count],params[:last_vector])

    render :partial=>'feeds/lists/feeds_stat',:locals=>{:feeds=>@feeds}
  end

  def inbox_logs_more
    @logs = current_user.inbox_logs_more(params[:current_id],params[:count])
    render :partial=>'index/userlog/userlog',:locals=>{:logs=>@logs}
  end

  def user_logs
    @logs = current_user.inbox_logs_limit(20)
  end

  def user_notices
    utp = UserTipProxy.new(current_user)
    @tips = utp.tips
  end

  def feedback
    
  end
end