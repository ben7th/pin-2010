class FeedsController < ApplicationController
  include FeedsControllerNavigationMethods

  before_filter :login_required,:except=>[:index,:no_reply,:newest,:search,:show,:aj_comments]

  before_filter :pre_load
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
    feed = current_user.send_feed(
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_ids      => params[:photo_ids],
      :collection_ids => params[:collection_ids],
      :from           => Feed::FROM_WEB,
      :send_tsina     => params[:send_tsina],
      :draft_token    => params[:draft_token],
      :location       => params[:location]
    )
    
    if feed.id.blank?
      flash[:error] = get_flash_error(feed)
      return redirect_to '/feeds/new'
    end
    redirect_to "/feeds/#{feed.id}"
  end

  def destroy
    @feed = Feed.find_by_id(params[:id])
    if current_user == @feed.creator
#      FeedOperationQueueWorker.async_feed_operate(FeedOperationQueueWorker::DESTROY_OPERATION,:feed_id=>params[:id])
#      return render :status=>200,:text=>"删除成功"
      @feed.destroy
      return redirect_to '/'
    end
    render :status=>401,:text=>"没有权限"
  end

  def fav
    current_user.add_fav_feed(@feed)
    render :stats=>200,:text=>"收藏成功"
  end

  def unfav
    current_user.remove_fav_feed(@feed)
    render :stats=>200,:text=>"取消收藏成功"
  end

  def aj_comments
    render :partial=>"feeds/show_parts/comments",
      :locals=>{:comments=>@feed.comments}
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
    if logged_in? && @feed.blank?
      @feed.save_viewed_by(current_user)  # 保存feed被用户查看过的记录
    end
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

  def edit
  end

  def update
    if @feed.creator != current_user
      return render_status_page(401,"没有权限")
    end
    @feed.update_all_attr(params[:title],params[:detail],
      params[:photo_ids],params[:photo_names],
      params[:collection_ids],params[:current_user])
    redirect_to "/feeds/#{@feed.id}"
  end
  
  def repost
  end

end
