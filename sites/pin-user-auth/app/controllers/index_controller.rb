class IndexController < ApplicationController
  def index
    if !logged_in?
      return render :template=>'auth/index',:layout=>'auth'
    end
    _user_page
  end

  def _user_page
    @workspaces = current_user.workspaces
    @organizations = Organization.of_user(current_user)
    @mindmaps = current_user.mindmaps
    @contacts = current_user.contacts
    news_feed_proxy = current_user.news_feed_proxy
    @feeds = news_feed_proxy.feeds.paginate(:per_page=>10,:page=>1)
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