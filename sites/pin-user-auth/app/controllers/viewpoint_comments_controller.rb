class ViewpointCommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
     @todo_user = TodoUser.find(params[:viewpoint_id]) if params[:viewpoint_id]
  end

  def destroy
    comment = TodoMemoComment.find(params[:id])
    if comment.user == current_user && comment.destroy 
      return render :text=>"destroy comment success",:status=>200
    end
    render :text=>"destroy comment failure",:status=>503
  end

  # post /viewpoints/:viewpoint_id/comments params[:content]
  def create
    comment = @todo_user.create_comment(current_user,params[:content])
    if comment.id
      return render :partial=>"index/homepage/feeds/show/viewpoint_comments_list",
      :locals=>{:comments=>[comment]}
    end
    render :status=>500,:text=>"create comments failure"
  end

  # get /viewpoints/:viewpoint_id/aj_comments
  def aj_comments
    render :partial=>"index/homepage/feeds/show/viewpoint_comments_list",
      :locals=>{:comments=>@todo_user.comments}
  end
end
