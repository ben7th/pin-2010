class ViewpointsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @viewpoint = Viewpoint.find(params[:id]) if params[:id]
  end

  # post /viewpoints/:id/feeds
  def create_feed
    feed = @viewpoint.create_viewpoint_feed(current_user,params[:content])
    if feed.id
      return render :text=>"create viewpoint feed success",:status=>200
    end
    render :text=>"create viewpoint feed failure",:status=>503
  end


  before_filter :vote_filter,:only=>[:vote_up,:vote_down,:cancel_vote]
  def vote_filter
    if @viewpoint.user == current_user
      return render :text=>503,:status=>503
    end
  end

  def vote_up
    @viewpoint.vote_up(current_user)
    render :partial=>"feeds/show_parts/feed_show_viewpoints",
      :locals=>{:feed=>@viewpoint.feed}
  end

  def vote_down
    @viewpoint.vote_down(current_user)
    render :partial=>"feeds/show_parts/feed_show_viewpoints",
      :locals=>{:feed=>@viewpoint.feed}
  end

  def cancel_vote
    @viewpoint.cancel_vote(current_user)
    render :partial=>"feeds/show_parts/feed_show_viewpoints",
      :locals=>{:feed=>@viewpoint.feed}
  end

end
