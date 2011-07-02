class IndexController < ApplicationController

  def index
    if !logged_in?
      render :layout=>'no_auth_index'
      return
    end

    redirect_to '/mindmaps'
  end
  
end