module UsersControllerMethods
  def new
    online_key = session[:online_key]
    reset_session
    session[:online_key] = online_key
    @user=User.new
    render :layout=>'anonymous',:template=>'index/signup'
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_remember_me_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # flash[:success]="注册成功，请使用新帐号登陆"
      login_after_create(@user)
    else
      flash.now[:error]=get_flash_error(@user)
      render :layout=>'anonymous',:template=>'index/signup'
    end
  end


  def login_after_create(user)
    self.current_user=user
    after_logged_in()
    redirect_to '/'
  end
end
