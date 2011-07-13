class IndexController < ApplicationController
  def index
    # 如果已经登录，访问首页
    if logged_in?
      #@mindmaps = current_user.in_mindmaps_paginate(:page=>params[:page]||1,:per_page=>20)
      @mindmaps = current_user.mindmaps.paginate(:page=>params[:page]||1,:per_page=>20)
      return
    end

    # 如果还没有登录，渲染登录页
    render :layout=>'anonymous',:template=>'index/login'
  end
end