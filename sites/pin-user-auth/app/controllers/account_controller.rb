class AccountController <  ApplicationController
  layout "account"
  before_filter :login_required

  before_filter :must_is_mindpin_account,:only=>[:do_unbind]
  def must_is_mindpin_account
    if !current_user.is_mindpin_typical_account?
      return render_status_page(503,"非法操作")
    end
  end

  before_filter :complete_reg_info_filter,:only=>[:do_setting_email,:complete_reg_info]
  def complete_reg_info_filter
    if !current_user.is_quick_connect_account?
      return render_status_page(503,"非法操作")
    end
  end

  # 基本信息
  def base
    if !params[:service].blank?
      session[:account_setting_from_site_flag] = params[:service]
    else
      session[:account_setting_from_site_flag] = ''
    end
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
    image_path = UserAvatarAdpater.path_by_image_file_name(@image_file_name)
    image = Magick::Image::read(File.new(image_path)).first
    @image_size = {:height=>image.rows,:width=>image.columns}
    return render :template=>"account/copper_avatared"
  end

  def _copper
    @image_file_path = UserAvatarAdpater.path_by_image_file_name(params[:image_file_name])
    current_user.copper_logo(@image_file_path,params)
    FileUtils.rm(@image_file_path)
    redirect_to :action=>:avatared
  end

  def do_setting_email
    email = params[:user][:email]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    error_message = []
    error_message.push("邮箱地址不能为空")  if email.blank?
    begin
      error_message.push("该邮箱已经被使用了") if !email.blank? && EmailActor.new(email).signed_in?
    rescue EmailActor::EmailFormatError=>ex
      error_message.push(ex.message)
    end
    error_message.push("密码不能为空") if password.blank?
    if !error_message.blank?
      flash[:error] = error_message.first
      return redirect_to :action=>:complete_reg_info
    end
    current_user.email = email
    current_user.password = password
    current_user.password_confirmation = password_confirmation
    if current_user.save
      flash[:success] = "账号注册信息补全成功"
      return _do_setting_email_success_to_redirect
    end
    flash[:error] = get_flash_error(current_user)
    redirect_to :action=>:complete_reg_info
  end

  def _do_setting_email_success_to_redirect
    if current_user.tsina_connect_user
      return redirect_to :action=>:bind_tsina
    end
    if current_user.renren_connect_user
      return redirect_to :action=>:bind_renren
    end
  end

  def complete_reg_info
  end

  def bind_tsina
  end

  def bind_renren
  end

  def do_unbind
    if params[:type] == "tsina"
      current_user.unbind_tsina_account
      return redirect_to :action=>:bind_tsina
    elsif params[:type] == "renren"
      current_user.unbind_renren_account
      return redirect_to :action=>:bind_renren
    end
  end

  def change_name
    @user = User.find(current_user.id)
    @user.valid?
    @user.errors.each_error do |attr,err|
      if attr == "name"
        if err.type == :invalid
          @message = "用户名不符合命名规范。为了保证内容质量，系统目前只允许使用纯中文或者纯英文数字的用户名。"
        else
          @message = err.message
        end
        return
      end
    end
  end

  def do_change_name
    @user = User.find(current_user.id)
    @user.update_attributes(params[:user])
    if @user.save
      return redirect_to "/"
    end
    flash.now[:error] = get_flash_error(@user)
    render :action=>:change_name
  end

  def do_tsina_connect_setting
    if params[:syn_from_connect] == "true"
      current_user.tsina_connect_user.set_syn_from_connect
    else
      current_user.tsina_connect_user.cancel_syn_from_connect
    end
    redirect_to "/account/bind_tsina"
  end

  def feed_form_show_detail_cookie
    cookies[:feed_form_show_detail] = params[:value]
    render :text=>200
  end

  def hide_startup
    current_user.do_hide_startup
    render :text=>200
  end

  def hide_new_feature_tips
    current_user.hide_new_feature_tips
    render :text=>200
  end

  def usage_setting
    return render(:template=>'account/usage_setting')
  end

  def set_usage
    current_user.set_usage(params[:usage])
    redirect_to "/"
  rescue Exception => ex
    render_status_page(503,'传入的值不正确')
  end
  
end
