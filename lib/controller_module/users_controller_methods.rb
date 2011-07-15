module UsersControllerMethods
  def new
    return _create_redirect_by_service if logged_in?

    @user=User.new
    render :layout=>'anonymous',:template=>'index/signup'
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_remember_me_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # flash[:success]="注册成功，请使用新帐号登陆"
      self.current_user=@user
      after_logged_in()
      _create_redirect_by_service
    else
      flash[:error]=get_flash_error(@user)
      redirect_to "/signup?service=#{params[:service]}"
    end
  end


  private
  def _create_redirect_by_service
    if params[:service] == "tu"
      redirect_to(pin_url_for("pin-daotu"))
    else
      redirect_to(root_url)
    end
  end
end
