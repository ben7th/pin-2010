module SessionsControllerMethods
  def self.included(base)
    # 登录表单不进行csrf校验
    base.skip_before_filter :verify_authenticity_token
  end

  # 登录
  def new
    if logged_in?
      return redirect_back_or_default(root_url)
    end

    render :layout=>'anonymous',:template=>'index/login'
  end

  # 创建session
  def create
    self.current_user = User.authenticate(params[:email],params[:password])

    if logged_in?
      after_logged_in()
      return redirect_back_or_default(root_url)
    else
      flash[:error]="邮箱/密码不正确"
      redirect_to "/"
    end
  end

  # 登出
  def destroy
    user = current_user

    if user
      reset_session_with_online_key()
      # 登出时销毁cookies令牌
      destroy_remember_me_cookie_token()
      destroy_online_record(user)
    end
    
    redirect_to root_url
  end
end
