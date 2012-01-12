class Account::ForgotPasswordController < ApplicationController

  # 忘记密码时，填写邮件的表单
  def form
    render :layout=>'anonymous'
  end

  # 根据邮件地址发送邮件
  def form_submit
    _deal_forgot_password(params[:email])
  rescue Exception=>ex
    flash[:error] = ex.message
  ensure
    redirect_to("/account/forgot_password")
  end

  def _deal_forgot_password(email)
    return flash[:error] = "请正确填写邮箱，我们才能帮你重设密码…" if email.blank?

    user = User.find_by_email(email)
    return flash[:error] = "对不起，不存在邮箱为 #{email} 的用户。" if user.blank?

    user.forgot_password
    flash[:success] = "重设密码邮件已经发送到邮箱 #{email}，请留意。"
  end

  # ------------------
  
  # 重置密码的表单
  def reset
    @user = User.find_by_reset_password_code(params[:pw_code])
    render :layout=>'anonymous'
  end

  # 重置密码
  def reset_submit
    @user = User.find_by_reset_password_code(params[:pw_code])
    return render_status_page(422, "重设密码请求序列号已经过期，请重新进行操作。") if @user.blank?

    user_param = params[:user]

    if _password_valid(user_param)
      @user.password = user_param[:password]
      @user.reset_password_code = nil
      if @user.save(:validate => false)
        flash.now[:success] = "已成功为 #{@user.email} 重设密码"
        render :layout=>'anonymous'
        return
      end
    end

    _reset_password_error(@user)
  end

  def _password_valid(user_param)
    !user_param[:password].blank? && user_param[:password] == user_param[:password_confirmation]
  end

  def _reset_password_error(user)
    user.errors.add(:password,"密码不能为空") if params[:user][:password].blank?
    user.errors.add(:password,"确认密码不能为空") if params[:user][:password_confirmation].blank?
    user.errors.add(:password_confirmation,"密码和确认密码必须相同") if params[:user][:password] != params[:user][:password_confirmation]
    flash[:error] = get_flash_error(user)
    redirect_to "/account/reset_password/#{params[:pw_code]}"
  end
end
