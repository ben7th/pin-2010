class CommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @comment = Comment.find(params[:id]) if params[:id]
    @note = Note.find(params[:note_id]) if params[:note_id]
  end

  def create
    comment = @note.comments.new(params[:comment])
    comment.user = current_user
    if comment.save
      return redirect_to show_note_path(@note)
    end
    redirect_to show_note_path(@note)
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
