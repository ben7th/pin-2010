class CommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
    @mindmap_comment = MindmapComment.find(params[:id]) if params[:id]
  end

  def new
  end

  def create
    create_feed = params[:create_feed] == "true" ? true : false
    if current_user.create_comment(@mindmap,params[:content],create_feed)
      return render :status=>200,:text=>"success"
    end
    return render :action=>:new
  end

  def destroy
    if current_user == @mindmap.user || current_user == @mindmap_comment.creator
      @mindmap_comment.destroy
      return render :status=>200,:text=>"success"
    end
    return render :status=>403,:text=>"无权限"
  end
  
end
