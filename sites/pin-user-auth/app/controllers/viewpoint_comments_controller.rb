class ViewpointCommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
     @viewpoint = Viewpoint.find(params[:viewpoint_id]) if params[:viewpoint_id]
  end

  def destroy
    comment = ViewpointComment.find(params[:id])
    if comment.user == current_user && comment.destroy 
      return render :text=>"destroy comment success",:status=>200
    end
    render :text=>"destroy comment failure",:status=>503
  end

  # post /viewpoints/:viewpoint_id/comments params[:content]
  def create
    comment = @viewpoint.create_comment(current_user,params[:content])
    if comment.id
      render :partial=>"feeds/show_parts/viewpoint_comments_list",
        :locals=>{:comments=>[comment]}
      return
    end
    render :status=>500,:text=>"观点评论创建失败"
  end

  # get /viewpoints/:viewpoint_id/aj_comments
  def aj_comments
    render :partial=>"feeds/show_parts/viewpoint_comments_list",
      :locals=>{:comments=>@viewpoint.comments}
  end
end
