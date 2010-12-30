class InvitationsController < ActionController::Base
  before_filter :login_required,:only=>[:create]
  include SessionsMethods

  before_filter :invitation_check,:only=>[:show,:regeist]
  def invitation_check
    @invitation = Invitation.find_by_code(params[:id])
    return render_status_page(404,'页面不存在') if @invitation.blank? || @invitation.activated?
  end

  def create
    inv = Invitation.new(:host_email=>current_user.email,:contact_email=>params[:invitation][:contact_email])
    if inv.save
      flash[:success] = "邀请函发送成功"
    else
      flash[:error] = get_flash_error(inv)
    end
    redirect_to "/account/invite"
  end

  def show
  end

  def regeist
    params[:user][:email] = @invitation.contact_email
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # 邀请 注册成功的逻辑
      @invitation.add_contacts
      login_after_create(@user)
    else
      flash.now[:error]=get_flash_error(@user)
      render :action=>:show
    end
  end

  def login_after_create(user)
    self.current_user=user
    after_logged_in()
    flash[:success] = '注册成功，激活邮件已经发送，您现在已经是 MindPin ei 的用户'
    redirect_back_or_default welcome_url
  end

end