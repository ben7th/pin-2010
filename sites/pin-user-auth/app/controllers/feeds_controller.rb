class FeedsController < ApplicationController
  before_filter :login_required,:except=>[:all,:search,:show,:aj_comments]
  before_filter :pre_load
  def pre_load
    @feed = Feed.find(params[:id]) if params[:id]
  end

  def do_say
    return _do_say_in_channel if params[:channel_id]
    _do_say_no_channel
  end
  
  def _do_say_no_channel
    feed = current_user.send_say_feed(params[:content],:detail=>params[:detail],:tags=>params[:tags])
    if feed.id.blank?
      return render :text=>get_flash_error(feed),:status=>403
    end
    str = @template.render :partial=>'feeds/lists/feeds_stat',:locals=>{:feeds=>[feed]}
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
      FeedOperationQueueWorker.async_feed_operate(FeedOperationQueueWorker::DESTROY_OPERATION,:feed_id=>params[:id])
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

  def viewpoint
    @todo_user = @feed.create_or_update_viewpoint(current_user,params[:content])
    render :partial=>"feeds/show_parts/info_feed_viewpoint_show",
      :locals=>{:todo_user=>@todo_user}
  end

  def aj_viewpoint_in_list
    @todo_user = @feed.create_or_update_viewpoint(current_user,params[:content])
    render :partial=>"feeds/info_parts/info_viewpoint",
      :locals=>{:feed=>@feed}
  end

  def favs
    @feeds = current_user.fav_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def memoed
    @feeds = current_user.memoed_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/memoed"
  end

  def be_invited
    @feeds = current_user.be_invited_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"feeds/be_invited"
  end

  def mine_hidden
    @feeds = current_user.hidden_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def all_hidden
    @feeds = Feed.hidden.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def all
    @feeds = Feed.recent_hot(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
  end

  def userlogs
    @userlogs = UserLog.paginate(:per_page=>30,:page=>params[:page]||1,:order=>'id desc')
  end


  def update_detail
    @feed.update_detail_content(params[:detail],current_user)
    render :partial=>'feeds/show_parts/feed_show',:locals=>{:feed=>@feed}
  end

  def update_content
    @feed.update_content(params[:content],current_user)
    render :partial=>'feeds/show_parts/show_page_head',:locals=>{:feed=>@feed}
  end

  def invite
    users = params[:user_ids].split(",").uniq.map{|id|User.find_by_id(id)}.compact
    return render :text=>"不能邀请自己",:status=>503 if users.include?(current_user)
    return render :text=>"不能邀请话题的创建者",:status=>503 if users.include?(@feed.creator)
    @feed.invite_users(users,current_user)
    render :partial=>'feeds/show_parts/invite_users',:locals=>{:feed=>@feed}
  end

  def cancel_invite
    user = User.find_by_id(params[:user_id])
    @feed.cancel_invite_user(user)
    render :text=>200
  end

  def send_invite_email
    @feed.send_invite_email(current_user,params[:email],params[:title],params[:postscript])
    render :text=>200
  end

  def save_viewpoint_draft
    @feed.save_viewpoint_draft(current_user,params[:content])
    render :text=>200
  end

  def add_spam_mark
    @feed.add_spam_mark(current_user)
    render :partial=>'feeds/show_parts/feed_show',:locals=>{:feed=>@feed}
  end

  def recover
    if @feed.can_be_recovered_by?(current_user)
      @feed.recover(current_user)
      return render :status=>200,:text=>"删除成功"
    end
    render :status=>401,:text=>"没有权限"
  end

  def add_tags
    @feed.add_tags(params[:tag_names])
    render :text=>200
  end

  def change_tags
    @feed.change_tags(params[:tag_names],current_user)
    render :partial=>'feeds/show_parts/show_page_head',:locals=>{:feed=>@feed}
  end

  def remove_tag
    @feed.remove_tag(params[:tag_name])
    render :text=>200
  end

  def lock
    if @feed.lock_by(current_user)
      return render :text=>200
    end
    return render :status=>401,:text=>401
  end

end
