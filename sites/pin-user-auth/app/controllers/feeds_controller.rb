class FeedsController < ApplicationController
  before_filter :login_required,:except=>[:index,:no_reply,:newest,:search,:show,:aj_comments]
  before_filter :pre_load
  skip_before_filter :verify_authenticity_token,:only=>[:create]
  before_filter :verify_authenticity_token_by_client,:only=>[:create]
  def verify_authenticity_token_by_client
    verify_authenticity_token unless is_android_client?
  end

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
    render :layout=>'create_form'
  end

  def create
    return _create_android_client if is_android_client?
    return _create_web
  end

  def _create_web
    feed = current_user.send_feed(params[:content],:detail=>params[:detail],:tags=>params[:tags],:sendto=>params[:sendto],:photo_names=>params[:photo_names])
    if feed.id.blank?
      flash[:error]=get_flash_error(feed)
      return redirect_to '/feeds/new'
    end
    redirect_to '/'
  end

  def _create_android_client
    feed = current_user.send_feed(params[:content],:detail=>params[:detail],:tags=>params[:tags],:sendto=>params[:sendto],:photo_names=>params[:photo_names])
    if feed.id.blank?
      return render :status=>422,:text=>422
    end
    return render :json=>feed
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

  def comments
    comment = @feed.comments.create(:content=>params[:content],:user=>current_user)
    unless comment.id.blank?
      return render :partial=>'feeds/lists/comments',
        :locals=>{:comments=>[comment]}
    end
    render :status=>403,:text=>"主题评论创建失败"
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
