ActionController::Routing::Routes.draw do |map|
  # ---------------- 首页和欢迎页面 ---------
  map.root :controller=>'index'
  map.welcome '/welcome',:controller=>'index',:action=>'welcome'
  map.connect "/in_feeds_more",:controller=>"index",:action=>"in_feeds_more"
  map.connect "/feedback",:controller=>"index",:action=>"feedback"
  
  map.connect "/services",:controller=>"activation",:action=>"services"
  map.connect "/activation",:controller=>"activation",:action=>"activation"
  map.connect "/do_activation",:controller=>"activation",:action=>"do_activation",
    :conditions=>{:method=>:post}
  map.connect "/apply",:controller=>"activation",:action=>"apply"
  map.connect "/do_apply",:controller=>"activation",:action=>"do_apply",
    :conditions=>{:method=>:post}

  # ---------------- 管理员后门 -------------
  map.connect '/zhi_ma_kai_men',
    :controller=>'rolling',
    :action=>'zhimakaimen',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/xb',
    :controller=>'rolling',
    :action=>'xb',
    :conditions=>{:method=>:get}

  # -----------------
  map.connect '/zhi_ma_kai_men/feeds/new',
    :controller=>'rolling',
    :action=>'new_feed',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/feeds/create',
    :controller=>'rolling',
    :action=>'create_feed',
    :conditions=>{:method=>:post}

  map.connect '/zhi_ma_kai_men/show/:id',
    :controller=>'rolling',
    :action=>'show_feed',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/feeds/:id/edit',
    :controller=>'rolling',
    :action=>'edit_feed',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/feeds/:id/update',
    :controller=>'rolling',
    :action=>'update_feed',
    :conditions=>{:method=>:post}

  # ------------------
  map.connect '/zhi_ma_kai_men/:feed_id/vp/new',
    :controller=>'rolling',
    :action=>'new_vp',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/:feed_id/vp/create',
    :controller=>'rolling',
    :action=>'create_vp',
    :conditions=>{:method=>:post}

  map.connect '/zhi_ma_kai_men/vp/:vp_id/edit',
    :controller=>'rolling',
    :action=>'edit_vp',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/vp/:vp_id/update',
    :controller=>'rolling',
    :action=>'update_vp',
    :conditions=>{:method=>:post}

  map.connect '/zhi_ma_kai_men/up_user_img/:user_id',
    :controller=>'rolling',
    :action=>'up_user_img',
    :conditions=>{:method=>:get}
  map.connect '/zhi_ma_kai_men/do_up_img/:user_id',
    :controller=>'rolling',
    :action=>'do_up_img',
    :conditions=>{:method=>:put}

  # ---------------- 用户认证相关 -----------
  map.login_ajax '/login_ajax',:controller=>'sessions',:action=>'new_ajax'
  map.login_fbox '/login_fbox',:controller=>'sessions',:action=>'login_fbox'
  map.login_fbox_create '/login_fbox_create',:controller=>'sessions',:action=>'login_fbox_create'
  map.login '/login',:controller=>'sessions',:action=>'new'
  map.login_by_extension '/login_by_extension',:controller=>'sessions',:action=>'login_by_extension'
  map.logout '/logout',:controller=>'sessions',:action=>'destroy'
  map.signup '/signup',:controller=>'users',:action=>'new'

  map.resource :session
  map.resources :users,:member=>{
    :cooperate=>:get,:feeds=>:get,:viewpoints=>:get,
    :favs=>:get,:logs=>:get
    },:collection=>{:fans=>:get,:followings=>:get,:reputation_rank=>:get,
      :feeds_rank=>:get,:viewpoints_rank=>:get
    }
  map.fans "/users/:user_id/fans",:controller=>"contacts",:action=>"fans"
  map.followings "/users/:user_id/followings",:controller=>"contacts",:action=>"followings"

  # 忘记密码
  map.forgot_password_form '/forgot_password_form',:controller=>'users',:action=>'forgot_password_form'
  map.forgot_password '/forgot_password',:controller=>'users',:action=>'forgot_password'
  # 重设密码
  map.reset_password '/reset_password/:pw_code',:controller=>'users',:action=>'reset_password'
  map.change_password '/change_password/:pw_code',:controller=>'users',:action=>'change_password'

  # ---- 起步指南相关 ----
  map.start_up_basic_setting '/startup/basic-setting',:controller=>'help',:action=>'basic_setting'
  map.start_up_edit_feed '/startup/edit-feed',:controller=>'help',:action=>'edit_feed'
  map.start_up_discuss '/startup/discuss',:controller=>'help',:action=>'discuss'
  map.start_up_friends '/startup/friends',:controller=>'help',:action=>'friends'

  # ----------------- 设置相关 -------------
  map.resource :preference,:collection=>{:selector=>:get,:ajax_theme_change=>:get}

  # 基本信息
  map.user_base_info "/account",:controller=>"account",:action=>"base",:conditions=>{:method=>:get}
  map.user_base_info_submit "/account",:controller=>"account",:action=>"base_submit",:conditions=>{:method=>:put}

  # 头像设置
  map.user_avatared_info "/account/avatared",:controller=>"account",:action=>"avatared",:conditions=>{:method=>:get}
  map.user_avatared_info_submit "/account/avatared",:controller=>"account",:action=>"avatared_submit",:conditions=>{:method=>:put}

  # 团队
  map.contacts_setting_organizations "contacts_setting/organizations",:controller=>"contacts_setting",:action=>"organizations"
  map.resources :organizations,:member=>{:invite=>:get,:settings=>:get,:leave=>:delete} do |organization|
    organization.resources :members
  end

  # 修改用户名
  map.change_name "account/change_name",:controller=>"account",
    :action=>"change_name",:conditions=>{:method=>:get}
  map.do_channge_name "account/change_name",:controller=>"account",
    :action=>"do_change_name",:conditions=>{:method=>:put}

  # 导入联系人
  map.import_contacts      "contacts_setting/import",:controller=>"contacts",:action=>"import"
  # 导入联系人 显示列表
  map.import_contacts_list "contacts_setting/import_list",:controller=>"contacts",:action=>"import_list"
  # 导入联系人
  map.resources :contacts,
    :collection=>{
      :create_for_plugin=>:post,
      :destroy_for_plugin=>:delete,
      :follow=>:post,
      :unfollow=>:delete
  }

  # 快速连接账号 设置邮箱，密码 变成 mindpin正式账号
  map.complete_reg_info "account/complete_reg_info",:controller=>"account",:action=>"complete_reg_info"
  map.do_setting_email "account/do_setting_email",:controller=>"account",:action=>"do_setting_email",:conditions=>{:method=>:post}
  # mindpin正式账号 绑定 外站账号
  map.account_bind_tsina "account/bind_tsina",:controller=>"account",:action=>"bind_tsina"
  map.account_bind_renren "account/bind_renren",:controller=>"account",:action=>"bind_renren"
  map.account_do_account_unbind "account/do_unbind",:controller=>"account",:action=>"do_unbind",:conditions=>{:method=>:post}
  map.account_do_tsina_syn_setting "account/do_tsina_connect_setting",
    :controller=>"account",:action=>"do_tsina_connect_setting",
    :conditions=>{:method=>:put}
  map.connect "/account/feed_form_show_detail_cookie",:controller=>"account",
    :action=>"feed_form_show_detail_cookie",:conditions=>{:method=>:put}

  map.connect "/account/hide_startup",:controller=>"account",
    :action=>"hide_startup",:conditions=>{:method=>:put}

  map.connect "/account/hide_new_feature_tips",:controller=>"account",
    :action=>"hide_new_feature_tips",:conditions=>{:method=>:put}

  map.connect "/account/set_usage",:controller=>"account",
    :action=>"set_usage",:conditions=>{:method=>:post}

  map.connect "/account/usage_setting",:controller=>"account",
    :action=>"usage_setting"

  # 发送邀请函
  map.contacts_setting_invite "contacts_setting/invite",:controller=>"contacts_setting",:action=>"invite"
  map.resources :invitations,:collection=>{:import_invite=>:post,:import_contact=>:post}

  map.invitation_do_register "/i/do_reg",:controller=>"users",:action=>"do_reg"
  map.invitation_register "/i/:user_id",:controller=>"invitations",:action=>"reg"

  # --杂项
  map.contact '/contact',:controller=>'misc',:action=>'contact'
  map.plugins '/plugins',:controller=>'misc',:action=>'plugins'

  map.connect_login "/connect_login",:controller=>"connect_users",:action=>"index"

  map.connect_tsina "/connect_tsina",:controller=>"connect_users",:action=>"connect_tsina"
  map.connect_tsina_callback "/connect_tsina_callback",:controller=>"connect_users",:action=>"connect_tsina_callback"

  map.connect_renren "/connect_renren",:controller=>"connect_users",:action=>"connect_renren"
  map.connect_renren_callback "/connect_renren_callback",:controller=>"connect_users",:action=>"connect_renren_callback"

  map.bind_other_site_tsina "/bind_other_site/tsina",:controller=>"connect_users",:action=>"bind_tsina"
  map.bind_other_site_tsina_callback "/bind_other_site/tsina_callback",:controller=>"connect_users",:action=>"bind_tsina_callback"
  map.update_bind_tsina_info "/bind_other_site/update_bind_tsina_info",:controller=>"connect_users",:action=>"update_bind_tsina_info",:conditions=>{:method=>:post}
  map.bind_other_site_tsina_failure "/bind_other_site/tsina_failure",:controller=>"connect_users",:action=>"bind_tsina_failure"

  map.bind_other_site_renren "/bind_other_site/renren",:controller=>"connect_users",:action=>"bind_renren"
  map.bind_other_site_renren_callback "/bind_other_site/renren_callback",:controller=>"connect_users",:action=>"bind_renren_callback"
  map.update_bind_renren_info "/bind_other_site/update_bind_renren_info",:controller=>"connect_users",:action=>"update_bind_renren_info",:conditions=>{:method=>:post}
  map.bind_other_site_renren_failure "/bind_other_site/renren_failure",:controller=>"connect_users",:action=>"bind_renren_failure"

  map.send_tsina_status "/connect_users/send_tsina_status",:controller=>"connect_users",:action=>"send_tsina_status",:conditions=>{:method=>:post}
  map.send_tsina_mindmap_thumb "/connect_users/send_tsina_mindmap",:controller=>"connect_users",:action=>"send_tsina_mindmap",:conditions=>{:method=>:post}
  map.send_tsina_status_with_logo "/connect_users/send_tsina_status_with_logo",:controller=>"connect_users",:action=>"send_tsina_status_with_logo",:conditions=>{:method=>:post}

  map.connect_confirm "/connect_confirm",:controller=>"connect_users",:action=>"connect_confirm"
  map.connect_confirm_create_quick_connect_account "/connect_confirm/create_quick_connect_account",:controller=>"connect_users",:action=>"create_quick_connect_account",:conditions=>{:method=>:post}
  map.connect_confirm_bind_mindpin_typical_account "/connect_confirm/bind_mindpin_typical_account",:controller=>"connect_users",:action=>"bind_mindpin_typical_account",:conditions=>{:method=>:post}

  map.resources :feeds,:member=>{
    :fav=>:post,:unfav=>:delete,:mine_newer_than=>:get,
    :aj_comments=>:get,:viewpoint=>:post,:aj_viewpoint_in_list=>:post,
    :update_detail=>:put,:update_content=>:put,:invite=>:post,:cancel_invite=>:delete,
    :send_invite_email=>:post,:save_viewpoint_draft=>:post,
    :recover=>:put,:add_spam_mark=>:post,
    :add_tags=>:post,:remove_tag=>:delete,:change_tags=>:put,
    :lock=>:put,:unlock=>:put,:comments=>:post
  },:collection=>{
    :friends=>:get,:newest=>:get,
    :recommend=>:get,:joined=>:get,
    :favs=>:get,:hidden=>:get,:no_reply=>:get,:search=>:get,
    :incoming=>:get
    } do |feed|
      feed.resources :feed_revisions,:as=>"revisions"
    end
  map.resources :feed_revisions,:member=>{:rollback=>:put}
  map.resources :user_logs,:collection=>{:friends=>:get,:newest=>:get}
    
  map.destroy_feed_comments "/feed_comments/:id",:controller=>"feed_comments",
    :action=>"destroy",:conditions=>{:method=>:delete}

  map.create_viewpoint_comment "/viewpoints/:viewpoint_id/comments",:controller=>"viewpoint_comments",
    :action=>"create",:conditions=>{:method=>:post}
  map.viewpoint_aj_comments "/viewpoints/:viewpoint_id/aj_comments",:controller=>"viewpoint_comments",
    :action=>"aj_comments"
  map.destroy_viewpoint_comment "/viewpoint_comments/:id",:controller=>"viewpoint_comments",
    :action=>"destroy",:conditions=>{:method=>:delete}
  
  map.create_viewpoint_feed "/viewpoints/:id/feeds",:controller=>"viewpoints",
    :action=>"create_feed",:conditions=>{:method=>:post}
  map.viewpoint_vote_up "/viewpoints/:id/vote_up",:controller=>"viewpoints",
    :action=>"vote_up",:conditions=>{:method=>:post}
  map.viewpoint_vote_down "/viewpoints/:id/vote_down",:controller=>"viewpoints",
    :action=>"vote_down",:conditions=>{:method=>:post}
  map.viewpoint_cancel_vote "/viewpoints/:id/cancel_vote",:controller=>"viewpoints",
    :action=>"cancel_vote",:conditions=>{:method=>:delete}

  map.resources :viewpoint_revisions,:as=>"revisions",:path_prefix=>"/viewpoints/:viewpoint_id"
  map.resources :viewpoint_revisions,:member=>{:rollback=>:put}

  map.user_feeds "newsfeed",:controller=>"feeds",:action=>"index"
  map.user_feeds_do_say "newsfeed/do_say",:controller=>"feeds",:action=>"do_say",:conditions=>{:method=>:post}
  map.newsfeed_new_count "newsfeed/new_count",:controller=>"feeds",:action=>"new_count"
  map.newsfeed_get_new "/newsfeed/get_new_feeds",:controller=>"feeds",:action=>"get_new_feeds"
  map.received_comments "/received_comments",:controller=>"feeds",:action=>"received_comments"
  
  map.resources :messages
  map.user_messages "/messages/user/:user_id",:controller=>"messages",:action=>"user_messages"

  map.resources :channels,:collection=>{
      :fb_orderlist=>:get,
      :sort=>:put,
      :none=>:get
    },:member=>{
      :add=>:put,
      :remove=>:put,
      :new_blog_post=>:get,
      :add_users=>:post,
      :newest_feed_ids=>:get
    }

  map.fans "/:user_id/channels",:controller=>"channels",:action=>"user_index"

  map.short_url "/short_url/:code",:controller=>"short_urls",:action=>"show"


  map.connect "/tips/remove_user_tip",:controller=>"tips",
    :action=>"remove_user_tip",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_all_user_tips",:controller=>"tips",
    :action=>"remove_all_user_tips",:conditions=>{:method=>:delete}

  map.resources :tags,:member=>{
    :logo=>:put,:upload_logo=>:get,:atom=>:get,:aj_info=>:get,
    :fav=>:post,:unfav=>:delete,:update_detail=>:put} do |tag|
      tag.resources :tag_detail_revisions,:as=>"revisions"
    end
  map.resources :tag_detail_revisions,:member=>{:rollback=>:put}

  map.resources :atmes

  map.resources :collections,:member=>{
    :change_name=>:put,
    :change_sendto=>:put,
    :add_feed=>:put
  }

  map.resources :photos,:collection=>{:feed_upload=>:post},:member=>{
    :comments=>:post,:add_description=>:put,
    :send_feed=>:get,:create_feed=>:post
  }
  map.resources :entries,:collection=>{:photos=>:get}

  # 主题邀请，提示

  map.resources :notices,:collection=>{:common=>:get,:invites=>:get}

  map.namespace :v2 do |v2|
    v2.connect "/chat",:controller=>"index",:action=>"chat"
    v2.connect "/chat_say",:controller=>"index",:action=>"chat_say",
      :conditions=>{:method=>:post}
  end
end
