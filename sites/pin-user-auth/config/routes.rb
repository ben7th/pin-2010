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

  map.account_password "/account/password",:controller=>"account",:action=>"password"
  map.account_do_password "/account/do_password",:controller=>"account",:action=>"do_password",:conditions=>{:method=>:put}
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
  map.account_contacts     "account/contacts",:controller=>"account",:action=>"contacts"
  # 导入联系人
  map.import_contacts      "account/contacts/import",:controller=>"contacts",:action=>"import"
  # 导入联系人 显示列表
  map.import_contacts_list "account/contacts/import_list",:controller=>"contacts",:action=>"import_list"
  # 导入联系人
  map.resources :contacts,
    :collection=>{
      :create_for_plugin=>:post,
      :destroy_for_plugin=>:delete,
      :follow=>:post,
      :unfollow=>:delete
  }
  map.fans "/:user_id/fans",:controller=>"contacts",:action=>"fans"
  map.fans "/:user_id/followings",:controller=>"contacts",:action=>"followings"

  # 新浪连接用户 设置邮箱
  map.setting_email "account/setting_email",:controller=>"account",:action=>"setting_email"
  map.do_setting_email "account/do_setting_email",:controller=>"account",:action=>"do_setting_email",:conditions=>{:method=>:post}
  map.account_rebind "account/rebind",:controller=>"account",:action=>"rebind"
  map.do_account_rebind "account/do_rebind",:controller=>"account",:action=>"do_rebind",:conditions=>{:method=>:post}

  # 发送邀请函
  map.account_invite "account/invite",:controller=>"account",:action=>"invite"
  map.resources :invitations,:collection=>{:import_invite=>:post,:import_contact=>:post}

  map.invitation_do_register "/i/do_reg",:controller=>"users",:action=>"do_reg"
  map.invitation_register "/i/:user_id",:controller=>"invitations",:action=>"reg"
  # 激活用户
  map.activate '/activate/:activation_code',:controller=>'account',:action=>'activate'

  # --杂项
  map.contact '/contact',:controller=>'misc',:action=>'contact'
  map.plugins '/plugins',:controller=>'misc',:action=>'plugins'

  # --旧版重定向
  map.old_map_redirect '/app/mindmap_editor/mindmaps/:id',:controller=>'misc',:action=>'old_map_redirect'


  map.connect_login "/connect_login",:controller=>"connect_users",:action=>"index"
  map.connect_sina "/connect_sina",:controller=>"connect_users",:action=>"connect_sina"
  map.connect_sina_callback "/connect_sina_callback",:controller=>"connect_users",:action=>"connect_sina_callback"

  map.connect_renren "/connect_renren",:controller=>"connect_users",:action=>"connect_renren"
  map.connect_sina_callback "/connect_renren_callback",:controller=>"connect_users",:action=>"connect_renren_callback"

  map.user_feeds "newsfeed",:controller=>"feeds",:action=>"index"
  map.user_feeds_do_say "newsfeed/do_say",:controller=>"feeds",:action=>"do_say"
  map.newsfeed_new_count "newsfeed/new_count",:controller=>"feeds",:action=>"new_count"
  map.newsfeed_get_new "/newsfeed/get_new_feeds",:controller=>"feeds",:action=>"get_new_feeds"
  
  map.resources :messages
  map.user_messages "/messages/user/:user_id",:controller=>"messages",:action=>"user_messages"
  map.account_message "/account/message",:controller=>"account",:action=>"message"
  map.account_do_message "/account/do_message",:controller=>"account",:action=>"do_message",:conditions=>{:method=>:put}

  map.resources :mindmaps,:collection=>{:import=>:get,:import_file=>:post},:member=>{
      :paramsedit=>:get,
      :clone_form=>:get,
      :do_clone=>:put,
    }

  #cooperations_controller
  map.cooperate_dialog "/cooperate/:mindmap_id",:controller=>"cooperations",:action=>"cooperate_dialog",:conditions=>{:method=>:get}
  map.save_cooperations "/save_cooperations/:mindmap_id",:controller=>"cooperations",:action=>"save_cooperations",:conditions=>{:method=>:post}

end
