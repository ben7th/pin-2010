class PostCommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
  end

  def create
    if params[:feed_id]
      return _create_feed_main_post_comment
    else
      return _create_post_comment
    end
  end

  def _create_feed_main_post_comment
    feed = Feed.find(params[:feed_id])
    comment = feed.add_comment(current_user,params[:content])
    render :partial=>'/feeds/parts/show_comments',:locals=>{:feed=>feed,:comments=>[comment]}
  rescue Exception => ex
    render :text=>ex.message,:status=>400
  end

  def destroy
  end

end
