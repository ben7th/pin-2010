class FeedsController < ApplicationController
  before_filter :login_required

  def index
    @feeds = current_user.news_feed_proxy.feeds
    @contacts = current_user.fans_contacts
  end

  def say;end

  def do_say
    feed = Feed.create(:email=>current_user.email,:event=>"say",:detail=>params[:detail])
    current_user.news_feed_proxy.update_feed(feed)
    redirect_to :action=>:index
  end

  def new_count
    newsfeed_ids = current_user.news_feed_proxy.newsfeed_ids
    new_fans_ids = ContactAttentionProxy.new(current_user).new_fans_ids
    render :json=>{:feed=>newsfeed_ids.count,:attention=>new_fans_ids.count}
  end

  def get_new_feeds
    current_user.news_feed_proxy.refresh_newest_feed_id
    newsfeeds = current_user.news_feed_proxy.newsfeed_ids(params[:after]).map{|id|Feed.find(id)}
    render :partial=>"index/homepage/feeds/new_feeds",:locals=>{:newsfeeds=>newsfeeds}
  end
  
end
