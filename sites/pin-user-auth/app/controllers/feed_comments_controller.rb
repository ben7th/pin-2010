class FeedCommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @feed_comment = FeedComment.find(params[:id]) if params[:id]
  end

  def destroy
    if @feed_comment.user == current_user && @feed_comment.destroy
      return render :text=>"destroy feed comment success",:status=>200
    end
    render :text=>"destroy feed comment failure",:status=>503
  end
end
