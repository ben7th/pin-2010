class ViewpointsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @todo_user = TodoUser.find(params[:id]) if params[:id]
  end

  # post /viewpoints/:id/feeds
  def create_feed
    feed = @todo_user.create_viewpoint_feed(current_user,params[:content])
    if feed.id
      return render :text=>"create viewpoint feed success",:status=>200
    end
    render :text=>"create viewpoint feed failure",:status=>503
  end


  before_filter :vote_filter,:only=>[:vote_up,:vote_down]
  def vote_filter
    if @todo_user.user == current_user
      return render :text=>503,:status=>503
    end
  end

  def vote_up
    @todo_user.vote_up(current_user)
    render :partial=>"feeds/show_parts/feed_show",
      :locals=>{:feed=>@todo_user.todo.feed}
  end

  def vote_down
    @todo_user.vote_down(current_user)
    render :partial=>"feeds/show_parts/feed_show",
      :locals=>{:feed=>@todo_user.todo.feed}
  end

end
