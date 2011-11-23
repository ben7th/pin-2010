class Account::SettingController <  ApplicationController
  layout "account"
  before_filter :login_required

  # 基本信息
  def base
    if !params[:call].blank?
      site = case params[:call]
      when 'tu'      then 'pin-daotu'
      when 'mindpin' then 'pin-user-auth'
      end

      session[:account_setting_from_site_flag] = site
    end
    # 否则不变
  end

    # 修改基本信息
  def base_submit
    @user= current_user

      if !params[:old_password].blank? && @user.is_mindpin_typical_account?
        return redirect_error_info("请输入新密码") if params[:new_password].blank?

        if (params[:new_password_confirmation] != params[:new_password])
          return redirect_error_info("新密码和确认新密码输入不相同")
        end

        u = User.authenticate(current_user.email,params[:old_password])
        if u.blank? || u != @user
          return redirect_error_info("旧密码输入错误")
        end

        @user.password=params[:new_password]
        @user.password_confirmation=params[:new_password_confirmation]
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


  # 头像
  def avatared;end

  # 修改头像 - 上传原始头像
  def avatared_submit_raw
    adpater = UserAvatarAdpater.new(current_user, params[:logo]).create_temp_file
    
    @temp_image_size = adpater.temp_image_size
    @temp_image_url  = adpater.temp_image_url

    return render :template=>"account/setting/copper_avatared"
  rescue
    flash[:error] = "图片上传失败"
    redirect_to :action=>:avatared
  end
  
  # 修改头像 - 裁切原始头像并保存到云
  def avatared_submit_copper
    UserAvatarAdpater.copper_logo(current_user, params[:x1], params[:y1], params[:width], params[:height])
    redirect_to :action=>:avatared
  rescue
    flash[:error] = "头像裁剪失败"
    redirect_to :action=>:avatared
  end
end
