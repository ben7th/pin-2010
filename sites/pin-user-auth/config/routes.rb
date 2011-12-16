include RoutesMethods

# -----------------

def match_activation_routes(map)  
  # 请求参与测试 / 提交请求参与测试表单
  match_get  map,'/apply'         => 'activation#apply'
  match_post map,'/apply_submit'  => 'activation#apply_submit'

  # 激活页面 / 激活请求表单提交
  match_get  map,'/activation'        => 'activation#activation'
  match_post map,'/activation_submit' => 'activation#activation_submit'
end

def match_auth_routes(map)
  # ---------------- 用户认证相关 -----------
  match_get  map, '/login'  => 'account/sessions#new'
  match_post map, '/login'  => 'account/sessions#create'
  match_get  map, '/logout' => 'account/sessions#destroy'

  match_get  map, '/signup'        => 'account/signup#form'
  match_post map, '/signup_submit' => 'account/signup#form_submit'
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

  match_get  map,'/users/:user_id/fans'       => 'contacts#fans'
  match_get  map,'/users/:user_id/followings' => 'contacts#followings'

  match_post map,'/contacts/follow_mindpin' => 'contacts#follow_mindpin'
  match_delete map,'/contacts/unfollow'       => 'contacts#unfollow'

  match_get  map,'/contacts'       => 'contacts#index'
  match_get  map,'/contacts/tsina' => 'contacts#tsina'
end

def match_forgot_password_routes(map)
  map.namespace(:account) do |account|
    match_get  account, 'forgot_password'                => 'forgot_password#form'
    match_post account, 'forgot_password/submit'         => 'forgot_password#form_submit'
    match_get  account, 'reset_password/:pw_code'        => 'forgot_password#reset'
    match_put  account, 'reset_password_submit/:pw_code' => 'forgot_password#reset_submit'
  end
end

def match_account_routes(map)
  map.namespace(:account) do |account|
    # 基本信息
    match_get  account, "/"                     => "setting#base"
    match_put  account, "/"                     => "setting#base_submit"

    # 头像设置
    match_get  account, "avatared"               => 'setting#avatared'
    match_post account, "avatared_submit_raw"    => 'setting#avatared_submit_raw'
    match_post account, "avatared_submit_copper" => 'setting#avatared_submit_copper'

    match_get  account, "tsina"                 => "tsina#index"
    # 设置中点击“关联新浪微博账号”按钮
    match_get  account, "tsina/connect"         => "tsina#connect"
    # 设置中“关联新浪微博账号”的callback
    match_get  account, "tsina/callback"        => "tsina#callback"
    # 设置中“关联新浪微博账号”关联失败，新浪微博账号已经关联过别的账号
    match_get  account, "tsina/connect_failure" => "tsina#connect_failure"
    # 关联新浪微博账号之后，在设置中手动更新新浪微博账号信息
    match_post account, "tsina/update_info"     => "tsina#update_info"
    # 取消新浪微博账号与当前账号关联
    match_post account, "tsina/disconnect"      => "tsina#disconnect"
  end
end

def match_connect_tsina_routes(map)
  # 与关联确认和补充账号信息相关的逻辑
  map.namespace(:account) do |account|
    match_get  account, "tsina_signup"        => "tsina_signup#index"
    match_post account, "tsina_signup/bind"   => "tsina_signup#bind"
    match_post account, "tsina_signup/create" => "tsina_signup#create"
  end

  map.namespace(:account) do |account|
    match_get  account, "complete"            => "complete#index"
    match_post account, "complete/submit"     => "complete#submit"
  end
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
      :public_timeline => :get
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
  match_post map, '/photos/upload_for_feed' => 'photos#upload_for_feed'
  match_post map, '/photos/import_image_url'=> 'photos#import_image_url'
end

def match_tsina_app_routes(map)
  map.namespace(:apps) do |apps|
    match_get apps, 'tsina/mindpin'              => 'tsina_app_mindpin#index'
    match_get apps, 'tsina/mindpin/connect'      => 'tsina_app_mindpin#connect'
    match_get apps, 'tsina/mindpin/callback'     => 'tsina_app_mindpin#callback'

    match_get apps, 'tsina/tu'                   => 'tsina_app_tu#index'
    match_get apps, 'tsina/tu/connect'           => 'tsina_app_tu#connect'
    match_get apps, 'tsina/tu/callback'          => 'tsina_app_tu#callback'

    match_get apps, 'tsina/schedule'             => 'tsina_app_schedule#index'
    match_get apps, 'tsina/schedule/connect'     => 'tsina_app_schedule#connect'
    match_get apps, 'tsina/schedule/callback'    => 'tsina_app_schedule#callback'
  end
end

######################################

ActionController::Routing::Routes.draw do |map|
  # ---------------- 首页和欢迎页面 ---------
  map.root :controller=>'index', :action=>'index'
  match_auth_routes(map)
  match_forgot_password_routes(map)
  match_account_routes(map)
  match_connect_tsina_routes(map)
  match_activation_routes(map)
  

  match_user_routes(map)
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

  match_tsina_app_routes(map)

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
    match_get    api0, 'collections/list'   => 'api#collection_list'
    match_post   api0, 'collections/create' => 'api#create_collection'
    match_delete api0, 'collections/delete' => 'api#delete_collection'
    match_put    api0, 'collections/rename' => 'api#rename_collection'

    # 主题 feeds
    match_get  api0, 'feeds/show'               => 'api#show'
    match_post api0, 'feeds/create'             => 'api#create'
    match_post api0, 'feeds/upload_photo'       => 'api#upload_photo'

    # 主题评论 comments

    match_get    api0, 'comments/list'   => 'api#feed_comments'
    match_post   api0, 'comments/create' => 'api#create_comment'
    match_delete api0, 'comments/delete' => 'api#delete_comment'
    match_post   api0, 'comments/reply'  => 'api#reply_comment'

    match_get    api0, 'comments/received' => 'api#comments_received'
    match_get    api0, 'comments/sent'     => 'api#comments_sent'

    # 人际关系 contacts
    match_get api0, 'contacts/followings' => 'api#contacts_followings'

    match_get api0, 'test' => "api#test"

  end

  match_get map, '/zhi_ma_kai_men/login_wallpapers/new'       => 'login_wallpapers#new'
  match_post map, '/zhi_ma_kai_men/login_wallpapers'             => 'login_wallpapers#create'
  match_get map, '/zhi_ma_kai_men/login_wallpapers'               => 'login_wallpapers#index'
  match_delete map, '/zhi_ma_kai_men/login_wallpapers/:id'      => 'login_wallpapers#destroy'

  match_get map,'/login_get_next_wallpaper' => "login_wallpapers#get_next_wallpaper"
  match_get map,'/login_get_prev_wallpaper' => "login_wallpapers#get_prev_wallpaper"

  map.namespace(:admin) do |admin|
    admin.resources :apply_records
  end
end
