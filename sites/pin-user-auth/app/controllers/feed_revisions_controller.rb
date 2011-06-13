class FeedRevisionsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @feed = Feed.find(params[:feed_id]) if params[:feed_id]
    @feed_revision = FeedRevision.find(params[:id]) if params[:id]
  end

  def show
  end

  def index
  end

  def rollback
    if current_user.is_admin?
      @feed_revision.rollback(current_user)
      return render :text=>200
    end
    render :text=>503,:status=>503
  end
end
