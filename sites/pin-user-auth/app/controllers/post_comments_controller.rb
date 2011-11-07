class PostCommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @feed = Feed.find(params[:feed_id]) if params[:feed_id]
    @comment = PostComment.find(params[:id]) if params[:id]
  end

  def create
    comment = @feed.add_comment(current_user,params[:content])
    render :partial=>'/feeds/parts/show_comments',:locals=>{:feed=>@feed,:comments=>[comment]}
  rescue Exception => ex
    render :text=>ex.message,:status=>400
  end

  def destroy
    if [@comment.post.feed.creator, @comment.user].include? current_user
      @comment.destroy
      return render :text=>'删除成功',:status=>200
    end
    render :text=>'你不能删除这条评论',:status=>403
  end

  def reply
    reply_to_comment = PostComment.find(params[:reply_comment_id])
    comment = reply_to_comment.add_reply(current_user, params[:content])
    render :partial=>'/feeds/parts/show_comments',:locals=>{:feed=>comment.post.feed,:comments=>[comment]}
  rescue Exception => ex
    render :text=>ex.message,:status=>400
  end

end
