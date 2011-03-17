class IndexController < ApplicationController
  def index
    if !logged_in?
      return render :template=>'auth/index',:layout=>'auth'
    end
    _user_page
  end

  def _user_page    
    @mindmaps = current_user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.paginate(:page=>params[:page]||1,:per_page=>21)
    @mindmaps_count = current_user.mindmaps_count

    fans = current_user.fans
    @fans_count = fans.count
    @fans = fans[0..7]

    followings = current_user.followings
    @followings_count = followings.count
    @channel_member_count = @followings_count
    @followings = followings[0..7]

    news_feed_proxy = current_user.news_feed_proxy
    @feeds = news_feed_proxy.feeds(:per_page=>10,:page=>1)
    news_feed_proxy.refresh_newest_feed_id
  end

  def updating
   redirect_to '/updating.html',:status=>301
  end

  def dev
    render_ui do |ui|
      ui.fbox :show,:title=>'bucuo',:partial=>'index/dev'
    end
  end

end