class IndexController < ApplicationController
  def index
    if logged_in?
      return redirect_to user_mindmaps_url(current_user)
    end
    return redirect_to mindmaps_url
  end

  def search
    begin
      @query = params[:q]
      @result = MindmapLucene.search_paginate(@query,:page=>params[:page] || 1)
    rescue Exception => ex
      p ex
      return render_status_page(500,'搜索服务出现异常或正在维护')
    end
  end

end
