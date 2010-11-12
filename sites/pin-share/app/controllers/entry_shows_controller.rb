class EntryShowsController < ApplicationController
  def new
  end

  def create
    render :action => "new"
  end

  def show
    @user = User.find(params[:user_id])
    respond_to do |format|
      format.js do
        render :layout=>false
      end
    end
  end

  def iframe
    @user = User.find(params[:user_id])
    @entry_show = params[:entry_show]
    if @entry_show[:style] == "new"
      @entries = Entry.user_of(@user).types_of(@entry_show[:types]).limited(@entry_show[:count]).by_created_at(:desc)
    elsif @entry_show[:style] == "rand"
      @entries = Entry.user_of(@user).types_of(@entry_show[:types]).order_by_rand.limited(@entry_show[:count])
    end
    render :layout=>"iframe"
  end
end
