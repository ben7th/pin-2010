class SessionsController < ApplicationController
  skip_before_filter :user_redirect
  skip_before_filter :verify_authenticity_token,:only=>[:login_by_extension]

  include SessionsMethods

  def new
    render :layout=>'auth',:template=>'auth/login'
  end

  def new_ajax
    if request.xhr?
      session[:return_to] = params[:return_url] if params[:return_url]
      render_ui do |ui|
        ui.fbox :show,:partial=>"sessions/form_login_ajax"
      end
    end
  end

  # 弹出框登录界面
  def login_fbox
    render :layout=>false
  end

  # 弹出框登陆界面提交后的处理
  def login_fbox_create
    self.current_user = User.authenticate(params[:email],params[:password])
    responds_to_parent do
      logged_in? ? login_success_and_refresh_page : login_failure
    end
  end

  # 登陆成功并刷新页面
  def login_success_and_refresh_page
    render_ui do |ui|
      ui.page << %`window.location.href=window.location.href;`
    end
  end

  # 登录失败，弹出提示
  def login_failure
    render_ui do |ui|
      ui.page << %`
        $$('.common_form .form_error').each(function(error){
          error.removeClassName('hide');
          error.update("<div class='flash-error'>用户名/密码不正确</div>");
        });
      `
    end
  end
  
  def create
    _login
  end

  def _login
    self.current_user=User.authenticate(params[:email],params[:password])
    if logged_in?
      after_logged_in()
      return redirect_back_or_default(root_url)
    else
      flash[:error]="邮箱/密码不正确"
      redirect_to login_url
    end
  end

  def destroy
    user=current_user
    if user
      reset_session_with_online_key()
      # 登出时销毁cookies令牌
      destroy_cookie_token()
      destroy_online_record(user)
    end
    redirect_to root_url
  end

  def login_by_extension
    self.current_user = (current_user ||User.authenticate(params[:email],params[:password]))
    if logged_in?
      after_logged_in()
      return render :status=>200,:text=>{:id=>current_user.id,:name=>current_user.name,:email=>current_user.email,:avatar=>current_user.logo.url()}.to_json
    end
    return render :status=>401,:text=>"用户名或者密码错误"
  end

end
