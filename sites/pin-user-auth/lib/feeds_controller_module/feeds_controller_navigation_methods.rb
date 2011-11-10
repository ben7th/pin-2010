module FeedsControllerNavigationMethods
  def index
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def public_timeline
    @feeds = Feed.public_timeline
  end

  def _index_login
    case cookies[:menu_feeds_tab]
    when "friends" then friends
    when "newest" then newest
    when "recommend" then recommend
    when "joined" then joined
    when "favs" then favs
    when "hidden" then hidden
    when "no_reply" then no_reply
    else
      friends
    end
  end

  def friends
    set_cookies_menu_feeds_tab "friends"
    @feeds = current_user.in_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/friends"
  end

  def newest
    set_cookies_menu_feeds_tab "newest"
    @feeds = Feed.normal.paginate(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
    render :template=>"feeds/newest"
  end

  def recommend
    set_cookies_menu_feeds_tab "recommend"
    @feeds = current_user.recommend_feeds(20)
    render :template=>"feeds/recommend"
  end

  def joined
    set_cookies_menu_feeds_tab "joined"
    @feeds = current_user.memoed_feeds_db.normal.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/joined"
  end

  def favs
    set_cookies_menu_feeds_tab "favs"
    @feeds = current_user.fav_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/favs"
  end

  def hidden
    set_cookies_menu_feeds_tab "hidden"
    @feeds = current_user.hidden_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/hidden"
  end

  def no_reply
    set_cookies_menu_feeds_tab "no_reply"
    @feeds = Feed.no_reply.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/no_reply"
  end

  private
  def set_cookies_menu_feeds_tab(name)
    cookies[:menu_feeds_tab] = name
  end

end
