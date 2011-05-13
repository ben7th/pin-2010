ActionController::Routing::Routes.draw do |map|
  # ---------------- 首页和欢迎页面 ---------
  map.root :controller=>'index'
  map.welcome '/welcome',:controller=>'index',:action=>'welcome'
  map.connect "/inbox_logs_more",:controller=>"index",:action=>"inbox_logs_more"
  map.connect "/in_feeds_more",:controller=>"index",:action=>"in_feeds_more"

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
    :favs=>:get
    }

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
  map.fans "/:user_id/fans",:controller=>"contacts",:action=>"fans"
  map.followings "/:user_id/followings",:controller=>"contacts",:action=>"followings"

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

  # 发送邀请函
  map.contacts_setting_invite "contacts_setting/invite",:controller=>"contacts_setting",:action=>"invite"
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
    :add_tags=>:post,:remove_tag=>:delete
  },:collection=>{
    :reply_to=>:post,:quote=>:post,:all=>:get,
    :memoed=>:get,:be_invited=>:get,
    :mine_hidden=>:get,:all_hidden=>:get
    } do |feed|
      feed.resources :todos,:collection=>{
        :remove_last_todo=>:delete
      }
    end
  map.destroy_feed_comments "/feed_comments/:id",:controller=>"feed_comments",
    :action=>"destroy",:conditions=>{:method=>:delete}
  map.resources :todos,:member=>{
    :add_memo=>:put,
    :clear_memo=>:put,
    :change_status=>:put,
    :assign=>:post,
    :unassign=>:delete,
    :move_to_first=>:put,
    :move_up=>:put,
    :move_down=>:put,
    :remove_last_todo_item=>:delete
  } do |todo|
    todo.resources :todo_items
  end
  map.resources :todo_items

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

  map.user_feeds "newsfeed",:controller=>"feeds",:action=>"index"
  map.user_feeds_do_say "newsfeed/do_say",:controller=>"feeds",:action=>"do_say",:conditions=>{:method=>:post}
  map.newsfeed_new_count "newsfeed/new_count",:controller=>"feeds",:action=>"new_count"
  map.newsfeed_get_new "/newsfeed/get_new_feeds",:controller=>"feeds",:action=>"get_new_feeds"
  map.favs "/favs",:controller=>"feeds",:action=>"favs"
  map.received_comments "/received_comments",:controller=>"feeds",:action=>"received_comments"
  map.quoted_me_feeds "/quoted_me_feeds",:controller=>"feeds",:action=>"quoted_me_feeds"
  map.feed_search "/search_feeds",:controller=>"feeds",:action=>"search"
  
  map.resources :messages
  map.user_messages "/messages/user/:user_id",:controller=>"messages",:action=>"user_messages"
  map.account_message "/account/message",:controller=>"account",:action=>"message"
  map.account_do_message "/account/do_message",:controller=>"account",:action=>"do_message",:conditions=>{:method=>:put}

  map.public_maps "/mindmaps/public",:controller=>"mindmaps",:action=>"public_maps"
  map.resources :mindmaps,:collection=>{
      :import_file=>:post,
      :aj_words=>:get,
      :cooperates=>:get
    },:member=>{
      :change_title=>:put,
      :clone_form=>:get,
      :do_clone=>:put,
      :do_private=>:put,
      :info=>:get,
      :share=>:post,
      :fav=>:post,
      :unfav=>:delete,
      :comments=>:post
    }
  map.user_mindmaps "/:user_id/mindmaps",:controller=>"mindmaps",:action=>"user_mindmaps"

  map.search_mindmaps '/search_mindmaps.:format',:controller=>'mindmaps_search',:action=>'search'

  #cooperations_controller
  map.add_cooperator "/cooperate/:mindmap_id/add_cooperator",
    :controller=>"cooperations",:action=>"add_cooperator",
    :conditions=>{:method=>:post}
  map.remove_cooperator "/cooperate/:mindmap_id/remove_cooperator",
    :controller=>"cooperations",:action=>"remove_cooperator",
    :conditions=>{:method=>:delete}

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

  map.create_html_document_feeds "/html_document_feeds",:controller=>"create_feeds",:action=>"html_document_feed",:conditions=>{:method=>:post}
  map.create_mindmap_feeds "/mindmap_feeds",:controller=>"create_feeds",:action=>"mindmap_feed",:conditions=>{:method=>:post}

  map.short_url "/short_url/:code",:controller=>"short_urls",:action=>"show"


  map.connect "/tips/remove_viewpoint_vote_up_tip",:controller=>"tips",
    :action=>"remove_viewpoint_vote_up_tip",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_all_viewpoint_vote_up_tips",:controller=>"tips",
    :action=>"remove_all_viewpoint_vote_up_tips",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_viewpoint_tip",:controller=>"tips",
    :action=>"remove_viewpoint_tip",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_all_viewpoint_tips",:controller=>"tips",
    :action=>"remove_all_viewpoint_tips",:conditons=>{:method=>:delete}
  map.connect "/tips/remove_feed_invite_tip",:controller=>"tips",
    :action=>"remove_feed_invite_tip",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_all_feed_invite_tips",:controller=>"tips",
    :action=>"remove_all_feed_invite_tips",:conditons=>{:method=>:delete}
  map.connect "/tips/remove_fav_feed_change_tip",:controller=>"tips",
    :action=>"remove_fav_feed_change_tip",:conditions=>{:method=>:delete}
  map.connect "/tips/remove_all_fav_feed_change_tips",:controller=>"tips",
    :action=>"remove_all_fav_feed_change_tips",:conditons=>{:method=>:delete}

  map.resources :tags,:member=>{:logo=>:put,:detail=>:put}
end
