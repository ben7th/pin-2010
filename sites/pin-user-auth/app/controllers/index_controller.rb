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
    @mindmaps = current_user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.paginate(:page=>params[:page]||1,:per_page=>21)
     
    @contacts = current_user.contacts
    news_feed_proxy = current_user.news_feed_proxy
    @feeds = news_feed_proxy.feeds.paginate(:per_page=>10,:page=>1)
    news_feed_proxy.refresh_newest_feed_id

    @mindmaps_count = current_user.mindmaps_count

    @fans_count = current_user.fans_contacts.count

    contacts_user = current_user.contacts_user
    @followings_count = contacts_user.count
    @followings = contacts_user[0..7]
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