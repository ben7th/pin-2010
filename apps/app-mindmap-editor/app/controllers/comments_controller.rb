class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    comment=Comment.new(params[:comment])
    if logged_in?
      comment.user=current_user
    end
    @mindmap=Mindmap.find(params[:mindmap_id])
    @mindmap.add_comment comment
    # 计算页码，翻到最后一页
    page_num=(@mindmap.comments.count-1) / per_page + 1
    @comments=@mindmap.comments.paginate :page=>page_num,:per_page=>per_page
    render :action=>'index'
  end
  
  def index
    @mindmap=Mindmap.find(params[:mindmap_id])
    @comments=@mindmap.comments.paginate :page=>params[:page],:per_page=>per_page
    if request.xhr?
      render :layout=>false
    else
      @pagetitle = "思维导图 - #{@mindmap.title} - 评论列表"
    end
  end
  
  private
  def per_page
    8
  end
end
