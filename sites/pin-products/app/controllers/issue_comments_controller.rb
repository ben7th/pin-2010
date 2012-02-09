class IssueCommentsController < ApplicationController
  before_filter :per_load
  def per_load
    @issue = Issue.find(params[:issue_id]) if params[:issue_id]
    @comment = IssueComment.find(params[:id]) if params[:id]
  end
  
  def create
    comment = @issue.comments.new(:content=>params[:content],:user=>current_user)
    if comment.save
      return redirect_to "/issues/#{@issue.id}"
    end
  end
  
  def reply
  end
  
  def do_reply
    comment = @comment.issue.comments.new(:content=>params[:content],:user=>current_user,:reply_to_comment=>@comment)
    if comment.save
      return redirect_to "/issues/#{@comment.issue.id}"
    end
  end
end
