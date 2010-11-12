class OldMindpinUrlRedirectController < ApplicationController
  def index
    redirect_to "/?oldverredirect=true"
  end
  
  def aboutus
    redirect_to "/aboutus?oldverredirect=true"
  end
  
  def index_mindmap
    redirect_to "/mindmaps?oldverredirect=true"
  end
  
  def my_mindmap
    redirect_to "/mindmaps/mine?oldverredirect=true"
  end
  
  def show_mindmap
    redirect_to "/mindmaps/#{params[:model_id]}?oldverredirect=true"
  end
  
  def edit_mindmap
    redirect_to "/mindmaps/#{params[:model_id]}/edit?oldverredirect=true"
  end
  
  def index_group
    redirect_to "/groups?oldverredirect=true"
  end
  
  def show_group
    redirect_to "/groups/#{params[:group_id]}?oldverredirect=true"
  end
  
end
