class UsersController < ApplicationController
  before_filter :login_required,:only => [:edit,:update]

  include SessionsMethods

  # forgot_password_form forgot_password reset_password change_password
  include ResetPasswordMethods

  def new
    online_key=session[:online_key]
    reset_session
    session[:online_key]=online_key
    @user=User.new
    render :layout=>'auth',:template=>'auth/signup'
  end

  def create
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # flash[:success]="注册成功，请使用新帐号登陆"
      login_after_create(@user)
    else
      flash.now[:error]=get_flash_error(@user)
      render :layout=>'auth',:template=>'auth/signup'
    end
  end

  def do_reg
    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # 邀请注册成功后，互相加为联系人
      InvitationEmail.new(params[:invition_sender_email],@user.email).done
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

  def show
    @user = User.find(params[:id])

    @mindmaps_count = @user.mindmaps_count
    if current_user == @user
      @mindmaps = @user.mindmaps.all(:order=>'id desc').paginate(:page=>params[:page]||1,:per_page=>21)
    else
      @mindmaps = @user.mindmaps.publics.paginate(:order=>'id desc',:page=>params[:page]||1,:per_page=>21)
    end

    @fans = @user.fans
    @fans_count = @user.fans_contacts.count

    contacts_user = @user.followings
    @followings_count = contacts_user.count
    @followings = contacts_user[0..9]

    @own_feeds = @user.news_feed_proxy.own_feeds.paginate(:page=>params[:page],:per_page=>20)
    
    set_cellhead_path('/index/cellhead')

    respond_to do |format|
      format.html {
        render :template=>'users/homepage'
      } # 这一行必须有而且必须在下面这行之前，否则IE里会出问题
      format.xml {
        render :xml=>@user.to_xml(:only=>[:id,:name,:created_at],:methods=>:logo)
      }
    end
  end

  def cooperate
    set_cellhead_path('/index/cellhead')
    @user = User.find(params[:id])
    @cooperate_edit_mindmaps = @user.cooperate_edit_mindmaps
    @cooperate_view_mindmaps = @user.cooperate_view_mindmaps
  end

  private
  def is_current_user?
    session[:user_id].to_s==params[:id]
  end

end
