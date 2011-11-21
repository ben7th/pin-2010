class Account::TsinaSignupController < ApplicationController
  include ConnectTsinaControllerMethods

  # 显示确认表单
  def index
    @tsina_user_info, connect_user = get_connect_user_from_session

    if !connect_user.blank?
      render_status_page(500,"新浪微博连接与用户数据不匹配")
    end

    # else
    # 没有关联过，新建账号或关联账号
    # confirm
  end

  def bind
    mindpin_user = User.authenticate(params[:email], params[:password])

    if mindpin_user.blank?
      flash[:error] = "邮箱/密码错误"
      return redirect_to_tsina_signup
    end
    
    unless mindpin_user.tsina_connect_user.blank?
      flash[:error] = "这个mindpin账号已经绑定了其它的新浪微博账号"
      return redirect_to_tsina_signup
    end

    bind_and_login_from_session(mindpin_user)
    redirect_to '/'
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_remember_me_cookie_token
    mindpin_user = User.new(params[:user])

    unless mindpin_user.save
      flash[:error] = get_flash_error(mindpin_user)
      flash[:mode]  = 2
      return redirect_to_tsina_signup
    end

    bind_and_login_from_session(mindpin_user)
    redirect_to '/'
  end


  private
    def redirect_to_tsina_signup
      redirect_to pin_url_for('pin-user-auth','/account/tsina_signup')
    end

    def bind_and_login_from_session(mindpin_user)
      atoken = session[:tsina_atoken]
      asecret = session[:tsina_asecret]

      tsina_user_info = Tsina.get_tsina_user_info_by_access_token(atoken,asecret)
      do_connect_user_bind_tsina(mindpin_user, tsina_user_info)

      self.current_user = mindpin_user #登录
      after_logged_in()
    end
  
end