class FeedsController < ApplicationController
  before_filter :login_required,:except=>[:index,:no_reply,:newest,:search,:show,:aj_comments]
  before_filter :pre_load
  include FeedsControllerNavigationMethods
  include FeedsControllerInviteMethods
  def pre_load
    @feed = Feed.find(params[:id]) if params[:id]
  end

  def incoming
    @feeds = current_user.incoming_feeds.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  def new
    # 创建主题的页面，do nothing here.
    @feed = Feed.new
  end

  def create
    feed = current_user.send_feed(params[:content],:detail=>params[:detail],:tags=>params[:tags],:sendto=>params[:sendto])
    if feed.id.blank?
      flash[:error]=get_flash_error(feed)
      return redirect_to '/feeds/new'
    end
    redirect_to '/'
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
    comment = Feed.reply_to_feed(current_user,params[:content],params[:send_new_feed],@host_feed,channel_param)
    if comment
      render :partial=>"feeds/show_parts/comments",
        :locals=>{:comments=>[comment]}
      return
    end
    return render :status=>403,:text=>"主题评论创建失败"
  end

  def aj_comments
    render :partial=>"feeds/show_parts/comments",
      :locals=>{:comments=>@feed.comments}
  end

  def received_comments
    @feed_comments = current_user.being_replied_comments.paginate(:per_page=>20,:page=>params[:page]||1)
  end

  # 搜索
  def search
    begin
      @query = params[:q]
      @result = FeedLucene.search_paginate(@query,:per_page=>20,:page=>params[:page]||1)
    rescue FeedLucene::FeedSearchFailureError => ex
      puts ex.backtrace*"\n"
      return render_status_page(500,ex)
    end
  end

  def show
    @feed = Feed.find(params[:id])
    @feed.view_by(current_user) if @feed && current_user
  end

  def viewpoint
    @viewpoint = @feed.create_or_update_viewpoint(current_user,params[:content])
    render :partial=>"feeds/show_parts/info_feed_viewpoint_show",
      :locals=>{:viewpoint=>@viewpoint}
  end

  def aj_viewpoint_in_list
    @viewpoint = @feed.create_or_update_viewpoint(current_user,params[:content])
    render :partial=>"feeds/info_parts/info_viewpoint",
      :locals=>{:feed=>@feed}
  end

  def update_detail
    @feed.update_detail_content(params[:detail],current_user)
    render :partial=>'feeds/show_parts/feed_show',:locals=>{:feed=>@feed}
  end

  def update_content
    @feed.update_content(params[:content],current_user)
    render :partial=>'feeds/show_parts/show_page_head',:locals=>{:feed=>@feed}
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
  end

  def change_tags
    @feed.change_tags(params[:tag_names],current_user)
    render :partial=>'feeds/show_parts/show_page_head',:locals=>{:feed=>@feed}
  end

  def remove_tag
  end

  def lock
    if @feed.lock_by(current_user)
      return render :text=>200
    end
    return render :status=>401,:text=>401
  end

  def unlock
    if @feed.unlock_by(current_user)
      return render :text=>200
    end
    return render :status=>401,:text=>401
  end

end
