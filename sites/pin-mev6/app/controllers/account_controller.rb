class AccountController <  ApplicationController
  before_filter :login_required

  # 基本信息
  def base;end
  # 头像
  def avatared;end

  # 修改基本信息
  def base_submit
    @user= current_user
    unless params[:old_password].blank?
      return redirect_error_info("请输入新密码") if params[:new_password].blank?

      if (params[:new_password_confirmation] != params[:new_password])
        return redirect_error_info("新密码和确认新密码输入不相同")
      end

      u = User.authenticate(current_user.email,params[:old_password])
      if u.blank? || u != @user
        return redirect_error_info("旧密码输入错误")
      end

      @user.password=params[:password]
      @user.password_confirmation=params[:password_confirmation]
    end

    @user.sign=params[:sign]
    @user.name=params[:name]
    if @user.save
      flash[:success]="用户 #{@user.email}（#{@user.name}）的信息已经成功修改"
    else
      flash[:error] = get_flash_error(@user)
    end
    return redirect_to :action=>:base
  end

  def redirect_error_info(error)
    flash[:error] = error
    redirect_to :action=>:base
  end

  # 修改头像
  def avatared_submit
    if !params[:copper]
      if params[:user].blank?
        flash.now[:error] = "头像保存失败，请选择头像图片并上传"
        return render :action=>:avatared
      end
      return _save_avatar
    else
      return _copper
    end
  end

  def _save_avatar
    @image_file_name = UserAvatarAdpater.create_by_upload_file(params[:user][:logo])
    @image_url = UserAvatarAdpater.url_by_image_file_name(@image_file_name)

    return render :template=>"account/copper_avatared"
  end

  def _copper
    @image_file_path = UserAvatarAdpater.path_by_image_file_name(params[:image_file_name])
    current_user.copper_logo(@image_file_path,params)
    redirect_to :action=>:avatared
  end

end
