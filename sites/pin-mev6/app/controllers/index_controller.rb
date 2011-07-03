class IndexController < ApplicationController
  def index
    if logged_in?
      @mindmaps = current_user.in_mindmaps_paginate(:page=>params[:page]||1,:per_page=>20)
      return
    end

    render :layout=>'anonymous',:template=>'index/login'
  end
end