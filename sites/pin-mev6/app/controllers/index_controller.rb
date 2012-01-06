class IndexController < ApplicationController
  before_filter :login_required, :only=>[:fav_maps]
  
  def index
    
    # 如果还没有登录，渲染登录页
    return render(:layout=>'anonymous', :template=>'index/login') if !logged_in?
    
    # 如果已经登录，访问首页
    @mindmaps = current_user.mindmaps.paginate(:page=>params[:page], :per_page=>20)
    render :template=>'index/index_maps'
  end
  
  def public_maps
    @mindmaps = Mindmap.publics.order('id DESC').paginate(:page=>params[:page], :per_page=>25)
  end
  
  def fav_maps
    @mindmaps = current_user.fav_mindmaps_paginate(:page=>params[:page], :per_page=>20)
  end
  
end