class UsersController < ApplicationController
  before_filter :login_required,:only => [:edit,:update]

  include SessionsMethods
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

    # 出于安全性考虑，新用户注册时销毁cookies令牌
    destroy_cookie_token
    @user=User.new(params[:user])
    if @user.save
      # 发送激活邮件
      @user.send_activation_mail
      # flash[:success]="注册成功，请使用新帐号登陆"
      login_after_create(@user)
    else
      flash.now[:error]=@user.errors.first[1]
      render :layout=>'auth',:template=>'auth/signup'
    end

  end

  def login_after_create(user)
    self.current_user=user
    after_logged_in()
    flash[:success] = '注册成功，激活邮件已经发送，您现在已经是 MindPin ei 的用户'
    redirect_back_or_default welcome_url
  end

  def show
    @user=User.find(params[:id])
    if logged_in? && @user == current_user
      @user_shares = @user.my_and_contacting_shares.paginate(:page => params[:page] ,:per_page=>30 )
    else
      @user_shares = @user.shares.paginate(:page => params[:page] ,:per_page=>30 )
    end
    respond_to do |format|
      format.html {} # 这一行必须有而且必须在下面这行之前，否则IE里会出问题
      format.xml {render :xml=>@user.to_xml(:only=>[:id,:name,:created_at],:methods=>:logo)}
    end
  end

  private
  def is_current_user?
    session[:user_id].to_s==params[:id]
  end

end
