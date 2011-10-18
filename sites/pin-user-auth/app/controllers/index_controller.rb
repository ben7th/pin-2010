class IndexController < ApplicationController
  def index
    # 当没有登录时，显示未登录的首页
    if logged_in? && current_user.is_v2_activation_user?
      @feeds = current_user.home_timeline({
        :count=>40
      })

      @collections = current_user.in_collections
      return render :template=>'index/index_page',:layout=>'collection'
    end

    # 如果还没有登录，渲染登录页
    render :layout=>'anonymous',:template=>'index/services'
  end
end