class AccountController <  ApplicationController
  before_filter :login_required,:except=>[:activate]

  before_filter :to_setting_email,:only=>[:password,:do_password,:email]
  def to_setting_email
    if EmailActor.get_mindpin_email(current_user) == current_user.email
      flash[:notice] = "你当前是使用外站帐号连接到 Mindpin！想要直接登录 Mindpin，你需要设置你的邮箱！"
      redirect_to :action=>:setting_email
    end
  end

  before_filter :rebind_filter,:only=>[:rebind,:on_rebind]
  def rebind_filter
    if EmailActor.get_mindpin_email(current_user) != current_user.email
      redirect_to :action=>:base
    end
  end

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
        set_cellhead_tail(:avatared)
        flash.now[:error] = "头像保存失败，请选择头像图片并上传"
        return render :action=>:avatared
      end
      return _save_avatar
    else
      return _copper
    end
  end

  def _save_avatar
    current_user.update_attributes({:logo=>params[:user][:logo]})
    set_cellhead_tail('copper_avatared')
    return render :template=>"account/copper_avatared"
  end

  def _copper
    current_user.copper_logo(params)
    redirect_to :action=>:avatared
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
    render :layout=>'auth'
  end

  # 团队首页
  def organizations; end

  def contacts
    @contacts = current_user.contacts
  end

  def invite;end

  def setting_email;end

  def do_setting_email
    email = params[:user][:email]
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    str = ""
    str ="邮箱地址不能为空"  if email.blank?
    str ="密码不能为空"  if password.blank?
    str = "该邮箱已经被使用了" if EmailActor.new(email).signed_in?
    if !str.blank?
      flash[:error] = str
      return redirect_to :action=>:setting_email
    end
    current_user.email = email
    current_user.password = password
    current_user.password_confirmation = password_confirmation
    if current_user.save
      flash[:success] = "设置成功"
      return redirect_to :action=>:base
    end
    flash[:error] = get_flash_error(current_user)
    redirect_to :action=>:setting_email
  end

  def rebind;end

  def do_rebind
    cu = ConnectUser.find_by_user_id(current_user.id)
    user = User.authenticate(params[:email],params[:password])
    if !!user
      self.current_user = user
      cu.rebind(current_user)
      return redirect_to :action=>:base
    end
    flash[:error] = "邮箱或者密码错误"
    redirect_to :action=>:rebind
  end

  def message
    @is_all_users = current_user.preference.messages_set == Preference::ALL_USERS
    @is_only_contacts = current_user.preference.messages_set == Preference::ONLY_CONTACTS
    if !@is_all_users && !@is_only_contacts
      @is_only_contacts = true
    end
  end
  
  def do_message
    set = params[:set]
    if [Preference::ALL_USERS,Preference::ONLY_CONTACTS].include?(set)
      current_user.preference.update_attributes(:messages_set=>set)
    end
    flash[:success] = "设置成功"
    redirect_to :action=>:message
  end

  def password;end

  def do_password
    begin
      current_user.change_password(params[:old_password],params[:new_password],params[:new_password_confirmation])
    rescue Exception => ex
      flash[:error] = ex.message
      return redirect_to :action=>:password
    end
    flash[:success] = "密码修改成功"
    redirect_to :action=>:password
  end
  
end
