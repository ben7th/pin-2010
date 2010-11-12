ActionController::Routing::Routes.draw do |map|
  map.root :controller=>'index'
  #  map.root :controller=>'index',:action=>'updating'
  map.welcome '/welcome',:controller=>'index',:action=>'welcome'
  # ---------------- 用户认证相关 -----------
  map.login_ajax '/login_ajax',:controller=>'sessions',:action=>'new_ajax'
  map.login_fbox '/login_fbox',:controller=>'sessions',:action=>'login_fbox'
  map.login_fbox_create '/login_fbox_create',:controller=>'sessions',:action=>'login_fbox_create'
  map.login '/login',:controller=>'sessions',:action=>'new'
  map.login_by_extension '/login_by_extension',:controller=>'sessions',:action=>'login_by_extension'
  map.logout '/logout',:controller=>'sessions',:action=>'destroy'
  map.signup '/signup',:controller=>'users',:action=>'new'

  map.resource :session
  map.resources :users

  # 忘记密码
  map.forgot_password_form '/forgot_password_form',:controller=>'users',:action=>'forgot_password_form'
  map.forgot_password '/forgot_password',:controller=>'users',:action=>'forgot_password'
  # 重设密码
  map.reset_password '/reset_password/:pw_code',:controller=>'users',:action=>'reset_password'
  map.change_password '/change_password/:pw_code',:controller=>'users',:action=>'change_password'


  # ----------------- 设置相关 ----------
  map.resource :preference,:collection=>{:selector=>:get,:ajax_theme_change=>:get}

  # 基本信息
  map.user_base_info "/account",:controller=>"account",:action=>"base",:conditions=>{:method=>:get}
  map.user_base_info_submit "/account",:controller=>"account",:action=>"base_submit",:conditions=>{:method=>:put}

  # 头像设置
  map.user_avatared_info "/avatared",:controller=>"account",:action=>"avatared",:conditions=>{:method=>:get}
  map.user_avatared_info_submit "/avatared",:controller=>"account",:action=>"avatared_submit",:conditions=>{:method=>:put}

  # 邮件
  map.user_email_info "/email",:controller=>"account",:action=>"email"
  map.send_activation_mail "/email/send_activation_mail",:controller=>"account",:action=>"send_activation_mail"
  # 激活用户
  map.activate '/activate/:activation_code',:controller=>'account',:action=>'activate'
end
