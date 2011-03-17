class FeedsController < ApplicationController
  before_filter :login_required
  before_filter :pre_load
  def pre_load
    @feed = Feed.find(params[:id]) if params[:id]
  end

  def index
    @feeds = current_user.news_feed_proxy.feeds
    @contacts = current_user.fans_contacts
  end

  def say;end

  def do_say
    feed = Feed.do_say(current_user,params[:content])
    str = @template.render :partial=>'index/homepage/feeds/new_feeds',:locals=>{:newsfeeds=>[feed]}
    render :text=>str
  end

  def do_say_temp
    channel_id = params[:channel_id]
    channel_id == "none" ? Feed.do_say(current_user,params[:content]) : Feed.do_say(current_user,params[:content],[channel_id])
    redirect_to "/channels/#{channel_id}"
  end

  def destroy
    @feed = Feed.find_by_id(params[:id])
    if current_user == @feed.creator
      FeedOperationQueue.new.add_destroy_feed_task(FeedOperationQueue::DESTROY_OPERATION,params[:id])
      return render :status=>200,:text=>"删除成功"
    end
    render :status=>401,:text=>"没有权限"
  end

  def new_count
    newsfeed_ids = current_user.news_feed_proxy.newsfeed_ids
    new_fans_ids = NewestFansProxy.new(current_user).newest_fans_ids
    render :json=>{:feed=>newsfeed_ids.count,:attention=>new_fans_ids.count}
  end

  def get_new_feeds
    current_user.news_feed_proxy.refresh_newest_feed_id
    newsfeeds = current_user.news_feed_proxy.newsfeed_ids(params[:after]).map{|id|Feed.find(id)}
    render :partial=>"index/homepage/feeds/new_feeds",:locals=>{:newsfeeds=>newsfeeds}
  end

  def fav
    current_user.add_fav_feed(@feed)
    render :stats=>200,:text=>"收藏成功"
  end

  def unfav
    current_user.remove_fav_feed(@feed)
    render :stats=>200,:text=>"取消收藏成功"
  end

end
