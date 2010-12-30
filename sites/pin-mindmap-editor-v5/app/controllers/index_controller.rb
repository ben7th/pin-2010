class IndexController < ApplicationController
  def index
    return redirect_to "/users/#{current_user.id}/mindmaps" if logged_in?
    return redirect_to "/mindmaps"
  end

  def search
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query,:page=>params[:page])
    rescue MindmapLucene::MindmapSearchFailureError => ex
      return render_status_page(500,ex)
    end
  end

end
