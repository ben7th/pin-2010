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
      flash[:success]="用户 #{@user.email}（#{@user.name}）的信息已经成功修改"
    else
      (@user.errors).each do |*error|
        flash[:error]=error*' '
      end
    end
    redirect_to :action=>:base
  end

  # 修改头像
  def avatared_submit
    if !params[:copper]
      if params[:user].blank?
        flash.now[:error] = "头像保存失败，请选择头像图片并上传"
        return render :action=>:avatared
      end
      current_user.update_attributes({:logo=>params[:user][:logo]})
      set_cellhead_tail('copper_avatared')
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
      return redirect_to :action=>:email
    end
    render_status_page(422,'当前邮箱已经激活，不能重复激活')
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

  # 团队首页
  def organizations; end

  def concats
    @concats = current_user.concats
  end
  
end
