def match_single_route(map, path, controller, action, method=:get)
  map.connect path,
    :controller=>controller,
    :action=>action,
    :conditions=>{:method=>method}
end

def match_get(map, config_hash)
  path = config_hash.keys[0]
  controller, action = config_hash.values[0].split('#')

  match_single_route map, path, controller, action, :get
end

def match_post(map, config_hash)
  path = config_hash.keys[0]
  controller, action = config_hash.values[0].split('#')

  match_single_route map, path, controller, action, :post
end

def match_delete(map, config_hash)
  path = config_hash.keys[0]
  controller, action = config_hash.values[0].split('#')

  match_single_route map, path, controller, action, :delete
end

def match_put(map, config_hash)
  path = config_hash.keys[0]
  controller, action = config_hash.values[0].split('#')

  match_single_route map, path, controller, action, :put
end

def match_activation_routes(map)
  # 选择导图服务或社区服务的页面
  match_get  map,'/services'      => 'activation#services'
  # 激活页面
  match_get  map,'/activation'    => 'activation#activation'
  # 激活请求表单提交
  match_post map,'/do_activation' => 'activation#do_activation'
  # 请求参与测试
  match_get  map,'/apply_form'    => 'activation#apply_form'
  # 提交请求参与测试表单
  match_post map,'/do_apply_form' => 'activation#do_apply_form'
end

def match_auth_routes(map)
  # ---------------- 用户认证相关 -----------
  map.login '/login',
    :controller=>'sessions',:action=>'new'
  map.logout '/logout',
    :controller=>'sessions',:action=>'destroy'
  map.signup '/signup',
    :controller=>'users',:action=>'new'

  map.resource :session
end

def match_user_routes(map)
  map.resources :users,
    :member=>{
      :cooperate=>:get,
      :feeds=>:get,
      :viewpoints=>:get,
      :favs=>:get,
      :logs=>:get
    },
    :collection=>{
      :fans=>:get,
      :followings=>:get,
      :reputation_rank=>:get,
      :feeds_rank=>:get,
      :viewpoints_rank=>:get
    }
  map.fans "/users/:user_id/fans",:controller=>"contacts",:action=>"fans"
  map.followings "/users/:user_id/followings",:controller=>"contacts",:action=>"followings"

  match_get  map,'/contacts'       => 'contacts#index'
  match_get  map,'/contacts/tsina' => 'contacts#tsina'
end

def match_forgot_password_routes(map)
  # 忘记密码
  map.forgot_password_form '/forgot_password_form',
    :controller=>'users',:action=>'forgot_password_form'
  map.forgot_password '/forgot_password',
    :controller=>'users',:action=>'forgot_password'
  # 重设密码
  map.reset_password '/reset_password/:pw_code',
    :controller=>'users',:action=>'reset_password'
  map.change_password '/change_password/:pw_code',
    :controller=>'users',:action=>'change_password'

  # 以后考虑放到单独的controller里
end

def match_account_routes(map)
  # 基本信息
  map.user_base_info "/account",
    :controller=>"account",:action=>"base",
    :conditions=>{:method=>:get}
  map.user_base_info_submit "/account",
    :controller=>"account",:action=>"base_submit",
    :conditions=>{:method=>:put}

  # 头像设置
  map.user_avatared_info "/account/avatared",
    :controller=>"account",:action=>"avatared",
    :conditions=>{:method=>:get}
  map.user_avatared_info_submit "/account/avatared",
    :controller=>"account",:action=>"avatared_submit",
    :conditions=>{:method=>:put}

  # mindpin正式账号 绑定 外站账号
  map.account_bind_tsina "/account/bind_tsina",
    :controller=>"account",:action=>"bind_tsina"
  map.account_bind_renren "/account/bind_renren",
    :controller=>"account",:action=>"bind_renren"
end

def match_connect_tsina_routes(map)
  # -- 关联 绑定 新浪微博
  map.connect "/connect_tsina",
    :controller=>"connect_tsina",:action=>"index"
  map.connect "/connect_tsina/callback",
    :controller=>"connect_tsina",:action=>"callback"
  map.connect "/connect_tsina/confirm",
    :controller=>"connect_tsina",:action=>"confirm"
  map.connect "/connect_tsina/complete_account_info",
    :controller=>"connect_tsina",:action=>"complete_account_info"
  map.connect "/connect_tsina/do_complete_account_info",
    :controller=>"connect_tsina",:action=>"do_complete_account_info",
    :conditions=>{:method=>:post}
  map.connect "/connect_tsina/bind",:controller=>"connect_tsina",
    :action=>"bind",:conditions=>{:method=>:post}
  map.connect "/connect_tsina/create",:controller=>"connect_tsina",
    :action=>"create",:conditions=>{:method=>:post}


  map.connect "/connect_tsina/account_bind",
    :controller=>"connect_tsina",:action=>"account_bind"
  map.connect "/connect_tsina/account_bind_callback",
    :controller=>"connect_tsina",:action=>"account_bind_callback"
  map.connect "/connect_tsina/account_bind_failure",
    :controller=>"connect_tsina",:action=>"account_bind_failure"
  map.connect "/connect_tsina/account_bind_update_info",
    :controller=>"connect_tsina",
    :action=>"account_bind_update_info",:conditions=>{:method=>:post}
  map.connect "/connect_tsina/account_bind_unbind",
    :controller=>"connect_tsina",:action=>"account_bind_unbind",
    :conditions=>{:method=>:post}
end

def match_feeds_routes(map)
  map.resources :feeds,
      :member=>{
      :fav                  =>:post,
      :unfav                =>:delete,
      :mine_newer_than      =>:get,
      :aj_comments          =>:get,
      :viewpoint            =>:post,
      :aj_viewpoint_in_list =>:post,
      :update_detail        =>:put,
      :update_content       =>:put,
      :invite               =>:post,
      :cancel_invite        =>:delete,
      :send_invite_email    =>:post,
      :save_viewpoint_draft =>:post,
      :recover              =>:put,
      :add_spam_mark        =>:post,
      :add_tags             =>:post,
      :remove_tag           =>:delete,
      :change_tags          =>:put,
      :lock                 =>:put,
      :unlock               =>:put,
      :repost               =>:get
    },
    :collection=>{
      :friends    =>:get,
      :newest     =>:get,
      :recommend  =>:get,
      :joined     =>:get,
      :favs       =>:get,
      :hidden     =>:get,
      :no_reply   =>:get,
      :search     =>:get,
      :incoming   =>:get,
      :all        =>:get
    } do |feed|
      feed.resources :feed_revisions,:as=>"revisions"
    end

    match_post map, '/feeds/:feed_id/comments' => 'post_comments#create'
    map.resources :post_comments, :collection=>{
      :reply => :post
    }
end

def match_viewpoints_routes(map)
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
end

def match_channels_routes(map)
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
end

def match_tags_routes(map)
  map.resources :tags,:member=>{
    :logo=>:put,:upload_logo=>:get,:atom=>:get,:aj_info=>:get,
    :fav=>:post,:unfav=>:delete,:update_detail=>:put} do |tag|
      tag.resources :tag_detail_revisions,:as=>"revisions"
    end
  map.resources :tag_detail_revisions,:member=>{:rollback=>:put}
end

def match_collections_routes(map)
  map.resources :collections,
    :collection=>{
      :tsina=>:get
    },
    :member=>{
      :change_name=>:put,
      :change_sendto=>:put,
      :add_feed=>:put
    }
end

def match_photos_and_entries_routes(map)
  map.resources :photos,:collection=>{:feed_upload=>:post},:member=>{
    :comments=>:post,:add_description=>:put,
    :send_feed=>:get,:create_feed=>:post
  }
  map.resources :entries,:collection=>{:photos=>:get}
end


ActionController::Routing::Routes.draw do |map|
  # ---------------- 首页和欢迎页面 ---------
  map.root :controller=>'index',:action=>'index'
  
  match_activation_routes(map)
  match_auth_routes(map)
  match_user_routes(map)
  match_forgot_password_routes(map)
  match_account_routes(map)
  match_connect_tsina_routes(map)
  
  match_feeds_routes(map)
  match_viewpoints_routes(map)
  map.resources :feed_revisions,:member=>{:rollback=>:put}
  map.resources :user_logs,:collection=>{:friends=>:get,:newest=>:get}
  
  map.resources :messages
  match_get map,'/messages/user/:user_id' => 'messages#user_messages'
  
  match_get map,'/short_url/:code'        => 'short_urls#show'

  match_channels_routes(map)
  match_tags_routes(map)

  map.resources :atmes

  match_collections_routes(map)

  match_photos_and_entries_routes(map)

  map.resources :notices,:collection=>{:common=>:get,:invites=>:get}

  map.resources :post_drafts

  match_get map,'/:user_id/contacts'          => 'contacts#index'
  match_get map,'/:user_id/feeds'             => 'feeds#index'
  match_get map,'/:user_id/collections'       => 'collections#index'
  match_get map,'/:user_id/collections/tsina' => 'collections#tsina'

  map.namespace(:api0) do |api0|
    # ---------------- 手机客户端同步数据 ----------
    match_get api0, 'mobile_data_syn'  => 'api#mobile_data_syn'
    match_get api0, 'home_timeline'    => 'api#home_timeline'

    # 收集册 collections
    match_get    api0, 'collections/feeds'  => 'api#collection_feeds'

    match_post   api0, 'collections/create' => 'api#create_collection'
    match_delete api0, 'collections/delete' => 'api#delete_collection'
    match_put    api0, 'collections/rename' => 'api#rename_collection'

    # 主题 feeds
    match_get  api0, 'feeds/show'               => 'api#show'
    match_post api0, 'feeds/create'             => 'api#create'
    match_post api0, 'feeds/upload_photo'       => 'api#upload_photo'
    match_post api0, 'feeds/create_with_photos' => 'api#create_with_photos'

    # 主题评论 comments

    match_get    api0, 'comments/list'   => 'api#feed_comments'
    match_post   api0, 'comments/create' => 'api#create_comment'
    match_delete api0, 'comments/delete' => 'api#delete_comment'
    match_post   api0, 'comments/reply'  => 'api#reply_comment'

    match_get    api0, 'comments/received'  => 'api#comments_received'

  end
end
