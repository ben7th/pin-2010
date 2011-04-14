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

  def all
    @feeds = Feed.find(:all,:order=>"created_at desc").paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def say;end

  def do_say
    return _do_say_in_channel if params[:channel_id]
    _do_say_no_channel
  end
  
  def _do_say_no_channel
    feed = current_user.send_say_feed(params[:content])
    if feed.blank?
      return render :text=>"发送失败",:status=>403
    end
    str = @template.render :partial=>'index/homepage/feeds/new_feeds',:locals=>{:newsfeeds=>[feed]}
    return render :text=>str
  end

  def _do_say_in_channel
    channel_id = params[:channel_id]
    channel = Channel.find_by_id(channel_id)
    return render :text=>"频道不存在",:status=>404 if channel.blank?
    feed = _send_feed_by_channel_kind(channel)
    return render :text=>"发送失败",:status=>403 if feed.blank?
    _render_content_by_channel_kind(channel,feed)
  end

  def _send_feed_by_channel_kind(channel)
    case channel.kind
    when Channel::KIND_INTERVIEW
      current_user.send_say_feed(params[:content],:channel_ids=>[channel.id])
    when Channel::KIND_TODOLIST
      current_user.send_todolist_feed(params[:content],:channel_ids=>[channel.id])
    else
      current_user.send_say_feed(params[:content],:channel_ids=>[channel.id])
    end
  end

  def _render_content_by_channel_kind(channel,feed)
    case channel.kind
    when Channel::KIND_INTERVIEW
      render_text = @template.render :partial=>'channels/channel_interview',:locals=>{:feeds=>[feed],:channel=>channel}
      render :text=>render_text
    when Channel::KIND_TODOLIST
      render_text = @template.render :partial=>'channels/channel_todolist',:locals=>{:feeds=>[feed],:channel=>channel}
      render :text=>render_text
    else
      render_text = @template.render :partial=>'index/homepage/feeds/new_feeds',:locals=>{:newsfeeds=>[feed]}
      render :text=>render_text
    end
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
    info = MessageTip.new(current_user).newest_info
    render :json=>info
  end

  def get_new_feeds
    mt = MessageTip.new(current_user)
    mt.refresh_feeds_info
    newsfeeds = mt.newest_feeds(params[:after])
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

  def reply_to
    @host_feed = Feed.find_by_id(params[:reply_to])
    channel_param = params[:channel_id].blank? ? [] : [params[:channel_id]]
    result = Feed.reply_to_feed(current_user,params[:content],params[:send_new_feed],@host_feed,channel_param)
    if result
      str = @template.render(:partial=>"index/homepage/feeds/feed_comment_info",:locals=>{:comment=>result})
      return render :text=>str
    end
    return render :status=>403,:text=>"error"
  end

  def aj_comments
    str = @template.render(
    :partial=>"index/homepage/feeds/feed_comment_list",
      :locals=>{:comments=>@feed.feed_comments,:feed=>@feed})
    render :text=>str
  end

  def favs
    @fav_feeds = current_user.fav_feeds(:per_page=>10,:page=>params[:page]||1)
  end

  def quote
    quote_feed = Feed.find(params[:quote_of])
    feed = Feed.to_quote_feed(current_user,params[:content],quote_feed)
    if feed
      return render :text=>"传阅成功"
    end
    render :status=>403,:text=>"传阅失败"
  end

  def received_comments
    @feed_comments = current_user.being_replied_comments.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def quoted_me_feeds
    @quoted_me_feeds = current_user.being_quoted_feeds
  end

  def search
    begin
      @query = params[:q]
      @result = FeedLucene.search_paginate(@query,:page=>params[:page]||1)
    rescue FeedLucene::FeedSearchFailureError => ex
      puts ex.backtrace*"\n"
      return render_status_page(500,ex)
    end
  end

  def show
    @feed = Feed.find(params[:id])
  end

  def update
    return (render :status=>403,:text=>"无权限") if @feed.creator != current_user
    if @feed.update_attributes(:content=>params[:content])
      return render :status=>200,:text=>"update success"
    end
    render :status=>500,:text=>"update failure"
  end
end
