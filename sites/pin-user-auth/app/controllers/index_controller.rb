class IndexController < ApplicationController
  def index
    # 如果已经登录，用户又通过了v2验证，则显示homeline页
    if logged_in? && current_user.is_v2_activation_user?
      @feeds = current_user.home_timeline(:count=>40)
      @collections = current_user.in_collections
      return render :template=>'index/index_page'
    end

    # 如果用户未通过v2验证

    # 如果已经登录，渲染服务列表页
    return render :layout=>'anonymous',:template=>'index/services' if logged_in?

    # 如果还没有登录，渲染未登录首页
    return render :layout=>'anonymous',:template=>'index/root'
  end
end