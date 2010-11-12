class AccountController < ActionController::Base
  before_filter :login_required,:except=>[:activate]
  # 基本信息
  def base;end
  # 头像
  def avatared;end
  # 邮箱
  def email;end

  # 修改基本信息
  def base_submit
    @user= current_user
    s1=params[:user]
    @user.password=s1[:password]
    @user.password_confirmation=s1[:password_confirmation]
    @user.update_attributes(s1)
    if @user.save
      flash[:notice]="用户#{@user.name}的信息已经成功修改"
    else
      (@user.errors).each do |*error|
        flash[:error]=error*' '
      end
    end
    redirect_to :action=>:base
    #    responds_to_parent do
    #      render_ui do |ui|
    #        ui.cell @user,:partial=>"users/cell_edit",:position=>:paper
    #        ui.page << %`
    #              $$("#logo_user_#{@user.id}").each(function(logo){
    #                logo.src = "#{@user.logo.url}";
    #              })
    #              $$("#logo_user_#{@user.id}_tiny").each(function(logo){
    #                logo.src = "#{@user.logo.url(:tiny)}";
    #              })
    #`
    #      end
    #    end
  end

  # 修改头像
  def avatared_submit
    if !params[:copper]
      if params[:user].blank?
        flash.now[:error] = "没有选择图片，请选择"
        return render :action=>:avatared
      end
      current_user.update_attributes({:logo=>params[:user][:logo]})
      return render :template=>"account/copper_avatared"
    else
      current_user.copper_logo(params)
      redirect_to :action=>:avatared
    end
  end

  # 发送激活邮件
  def send_activation_mail
    if !current_user.activated?
      current_user.send_activation_mail
      flash[:notice]="激活邮件已发送，请注意查收"
      redirect_to :action=>:email
    end
  end

  # 用户激活
  def activate
    @user = User.find_by_activation_code(params[:activation_code])
    if @user
      @user.activate
    else
      @failure = true
    end
  end
  
end
