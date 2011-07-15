class CommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
    @mindmap_comment = MindmapComment.find(params[:id]) if params[:id]
  end

  def new
  end

  def create
    comment = @mindmap.comments.create(:creator=>current_user ,:content=>params[:content])
    render :partial=>'mindmaps/lists/comments',:locals=>{:comments=>[comment]}
  end

  def destroy
    @mindmap = @mindmap_comment.mindmap
    if current_user == @mindmap.user || current_user == @mindmap_comment.creator
      @mindmap_comment.destroy
      return render :status=>200,:text=>"success"
    end
    return render :status=>403,:text=>"无权限"
  end
  
end
