class SessionsController < ApplicationController
  include SessionsMethods

  def new
    if logged_in?
      return redirect_back_or_default(root_url)
    end
    render :template=>'auth/login'
  end

  def create
    self.current_user=User.authenticate(params[:email],params[:password])
    if logged_in?
      after_logged_in()
      return redirect_back_or_default(root_url)
    else
      flash[:error]="邮箱/密码不正确"
      redirect_to "/"
    end
  end

  def destroy
    user=current_user
    if user
      reset_session_with_online_key()
      # 登出时销毁cookies令牌
      destroy_cookie_token()
      destroy_online_record(user)
    end
    redirect_to root_url
  end

end
