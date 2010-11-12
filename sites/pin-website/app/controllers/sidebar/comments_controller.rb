class Sidebar::CommentsController < ApplicationController
  layout "sidebar"
  before_filter :login_required
  before_filter :pre_load
  def pre_load
    @comment = Comment.find(params[:id]) if params[:id]
  end

  def create
    comment = Comment.new(params[:comment])
    comment.creator = current_user
    if comment.save
      render_ui do |ui|
        ui.mplist :insert,comment,:partial=>"sidebar/comments/parts/mpinfo_comment",:locals=>{:comment=>comment},:prev=>"TOP"
        ui.page << "jQuery('#comment_content').val('')"
      end
    end
  end

  def index;end
  
  def destroy
    @comment.destroy
    render_ui do |ui|
      ui.mplist :remove, @comment
    end
  end
  
end