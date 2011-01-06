ActionController::Routing::Routes.draw do |map|
  # ---------------- 首页和欢迎页面 ---------
  map.root :controller=>'index'
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

  # ----------------- 设置相关 -------------
  map.resource :preference,:collection=>{:selector=>:get,:ajax_theme_change=>:get}

  # 基本信息
  map.user_base_info "/account",:controller=>"account",:action=>"base",:conditions=>{:method=>:get}
  map.user_base_info_submit "/account",:controller=>"account",:action=>"base_submit",:conditions=>{:method=>:put}

  # 头像设置
  map.user_avatared_info "/account/avatared",:controller=>"account",:action=>"avatared",:conditions=>{:method=>:get}
  map.user_avatared_info_submit "/account/avatared",:controller=>"account",:action=>"avatared_submit",:conditions=>{:method=>:put}

  # 邮件
  map.user_email_info "/account/email",:controller=>"account",:action=>"email"
  map.send_activation_mail "/account/email/send_activation_mail",:controller=>"account",:action=>"send_activation_mail"

  # 团队
  map.account_organizations "account/organizations",:controller=>"account",:action=>"organizations"
  map.resources :organizations,:member=>{:invite=>:get,:settings=>:get,:leave=>:delete} do |organization|
    organization.resources :members
  end

  # 联系人
  map.account_concats     "account/concats",:controller=>"account",:action=>"concats"
  # 导入联系人
  map.import_concats      "account/concats/import",:controller=>"concats",:action=>"import"
  # 导入联系人 显示列表
  map.import_concats_list "account/concats/import_list",:controller=>"concats",:action=>"import_list"
  # 导入联系人
  map.resources :concats,
    :collection=>{
      :create_all=>:post,
      :create_for_plugin=>:post,
      :destroy_for_plugin=>:delete
  }

  # 发送邀请函
  map.account_invite "account/invite",:controller=>"account",:action=>"invite"
  map.resources :invitations,:member=>{:regeist=>:post},:collection=>{:import_invite=>:post}

  map.invitation_do_register "/i/do_reg",:controller=>"users",:action=>"do_reg"
  map.invitation_register "/i/:user_id",:controller=>"invitations",:action=>"reg"
  # 激活用户
  map.activate '/activate/:activation_code',:controller=>'account',:action=>'activate'

  # --杂项
  map.concat '/concat',:controller=>'misc',:action=>'concat'
  map.plugins '/plugins',:controller=>'misc',:action=>'plugins'

  # --旧版重定向
  map.old_map_redirect '/app/mindmap_editor/mindmaps/:id',:controller=>'misc',:action=>'old_map_redirect'
end
