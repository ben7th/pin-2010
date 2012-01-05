# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ApplicationMethods
  helper :all

  #--------------------------------------------------

  around_filter :catch_oauth_exception
  def catch_oauth_exception
    yield
  rescue Tsina::OauthFailureError=>tsina_error
    if request.xhr?
      return render :text=>tsina_error.message,:status=>503
    else
      return render_status_page(503, "新浪微博API认证错误：#{tsina_error.message}")
    end
  end

  #------------------------

  # 未登录或者未激活时，能够访问的页面
  ANONYMOUS_FREE_PAGES = {
    :index => [:index],
    :activation => [
      :services,
      :apply, :apply_submit,
      :activation, :activation_submit
    ],
    # 登录，登出
    :'account/sessions' => [:new,:create,:destroy],
    
    # 注册
    :'account/signup' => [
      :form, :form_submit
    ],

    # 忘记密码
    :'account/forgot_password' => [
      :form, :form_submit,
      :reset, :reset_submit
    ],

    # 用户设置
    :'account/setting' => [
      :base, :base_submit,
      :avatared, :avatared_submit_raw, :avatared_submit_copper
    ],
    
    # 用户设置 新浪微博绑定相关
    :'account/tsina' => [
      :index,
      :connect,
      :callback,
      :connect_failure,
      :update_info,
      :disconnect
    ],

    # 几个应用的新浪微博入口
    :'apps/tsina_app_tu'       =>[:index,:connect,:callback],
    :'apps/tsina_app_schedule' =>[:index,:connect,:callback],
    :'apps/tsina_app_mindpin'  =>[:index,:connect,:callback],

    # 主要新浪微博连接方法
    :'account/tsina_signup' => [:index,:bind,:create],
    :'account/complete'     => [:index,:submit],

    # 个人页 / 主题页
    :users => [:show],
    :feeds => [:show],


    :contacts =>[
      :follow,
      :unfollow,
      :followings,
      :fans,
      :create
    ],
    :login_wallpapers=>[
      :index,
      :new,
      :create,
      :destroy,
      :get_next,
      :get_prev
    ]
  }
  before_filter :hold_anonymous_free_page
  def hold_anonymous_free_page
    # 如果已登录，并且当前用户已经v2激活，任意放行
    return true if (logged_in? && current_user.is_v2_activation_user?)

    # 如果未登录或未激活，特定页面放行
    return true if _is_anonymous_free_page?
    
    # 其他用户，重定向处理
    return render :status=>401,:text=>401 if is_android_client? # android客户端，401
    return redirect_to "/"
  end

  def _is_anonymous_free_page?
    controller = params[:controller].to_sym
    action     = params[:action].to_sym

    pass_actions = ANONYMOUS_FREE_PAGES[controller]
    return true if !!pass_actions && pass_actions.include?(action) #指定action，放行PASS
    return false
  end

  #--------------------------

  def to_updating_page
    redirect_to pin_url_for("ui","updating.html")
  end

end