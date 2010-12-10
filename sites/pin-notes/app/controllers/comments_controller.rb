class CommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @comment = Comment.find(params[:id]) if params[:id]
    @note = Note.find_by_id(params[:note_id]) if params[:note_id]
    @note = Note.find_by_private_id(params[:note_id]) if @note.blank? && params[:note_id]
  end

  def create
    comment = @note.comments.new(params[:comment])
    comment.user = current_user
    if comment.save
      return redirect_to note_path(:id=>@note.nid)
    end
    redirect_to note_path(:id=>@note.nid)
  end

  def update
    @comment.update_attributes(params[:comment])
    if @comment.save
      render_ui.mplist :update,@comment
    end
  end

  def destroy
    @comment.destroy
    render_ui.mplist :remove,@comment
  end

end
