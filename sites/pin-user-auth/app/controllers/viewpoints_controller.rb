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

end
