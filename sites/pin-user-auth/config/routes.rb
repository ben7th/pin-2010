# -- 用户认证相关 --
def match_auth_routes
  get  '/login'  => 'account/sessions#new'
  post '/login'  => 'account/sessions#create'
  get  '/logout' => 'account/sessions#destroy'

  get  '/signup'        => 'account/signup#form'
  post '/signup_submit' => 'account/signup#form_submit'
end

# -- 随机壁纸 --
def match_login_wallpaper_routes
  get    '/zhi_ma_kai_men/login_wallpapers/new' => 'login_wallpapers#new'
  post   '/zhi_ma_kai_men/login_wallpapers'     => 'login_wallpapers#create'
  get    '/zhi_ma_kai_men/login_wallpapers'     => 'login_wallpapers#index'
  delete '/zhi_ma_kai_men/login_wallpapers/:id' => 'login_wallpapers#destroy'

  get '/login/wallpapers/:id/next' => 'login_wallpapers#get_next'
  get '/login/wallpapers/:id/prev' => 'login_wallpapers#get_prev'
end

# -- 忘记密码 --
def match_forgot_password_routes
  namespace :account do
    get  'forgot_password'                => 'forgot_password#form'
    post 'forgot_password/submit'         => 'forgot_password#form_submit'
    get  'reset_password/:pw_code'        => 'forgot_password#reset'
    put  'reset_password_submit/:pw_code' => 'forgot_password#reset_submit'
  end
end

# -- 设置 --
def match_account_routes
  namespace :account do
    # 基本信息
    get  "/"                     => "setting#base"
    put  "/"                     => "setting#base_submit"

    # 头像设置
    get  "avatared"               => 'setting#avatared'
    post "avatared_submit_raw"    => 'setting#avatared_submit_raw'
    post "avatared_submit_copper" => 'setting#avatared_submit_copper'

    get  "tsina"                 => "tsina#index"
    # 设置中点击“关联新浪微博账号”按钮
    get  "tsina/connect"         => "tsina#connect"
    # 设置中“关联新浪微博账号”的callback
    get  "tsina/callback"        => "tsina#callback"
    # 设置中“关联新浪微博账号”关联失败，新浪微博账号已经关联过别的账号
    get  "tsina/connect_failure" => "tsina#connect_failure"
    # 关联新浪微博账号之后，在设置中手动更新新浪微博账号信息
    post "tsina/update_info"     => "tsina#update_info"
    # 取消新浪微博账号与当前账号关联
    post "tsina/disconnect"      => "tsina#disconnect"

    # --------- 社区用户设置
    get  'head_cover' => 'preferences#head_cover'
    post 'head_cover' => 'preferences#head_cover_submit'
  end
end

# -- 新浪微博连接 --
def match_connect_tsina_routes
  # 与关联确认和补充账号信息相关的逻辑
  namespace :account do
    get  "tsina_signup"        => "tsina_signup#index"
    post "tsina_signup/bind"   => "tsina_signup#bind"
    post "tsina_signup/create" => "tsina_signup#create"
  end

  namespace :account do
    get  "complete"            => "complete#index"
    post "complete/submit"     => "complete#submit"
  end
end

# -- 内测与激活 --
def match_activation_routes 
  # 请求参与测试 / 提交请求参与测试表单
  get  '/apply'         => 'activation#apply'
  post '/apply_submit'  => 'activation#apply_submit'

  # 激活页面 / 激活请求表单提交
  get  '/activation'        => 'activation#activation'
  post '/activation_submit' => 'activation#activation_submit'
end

# -- 用户资源 --
def match_user_routes
  resources :users do
    member do
      get :cooperate
      get :feeds
      get :viewpoints
      get :favs
      get :logs
    end
    collection do
      get :fans
      get :followings
      get :reputation_rank
      get :feeds_rank
      get :viewpoints_rank
    end
  end

  get  '/users/:user_id/fans'       => 'contacts#fans'
  get  '/users/:user_id/followings' => 'contacts#followings'

  post '/contacts/follow_mindpin'   => 'contacts#follow_mindpin'
  delete '/contacts/unfollow'       => 'contacts#unfollow'

  get  '/contacts'       => 'contacts#index'
  get  '/contacts/tsina' => 'contacts#tsina'
end

def match_feeds_routes
  resources :feeds do
    member do
      post   :fav
      delete :unfav
      get    :mine_newer_than
      get    :aj_comments
      post   :viewpoint
      post   :aj_viewpoint_in_list
      put    :update_detail
      put    :update_content
      post   :save_viewpoint_draft
      put    :recover
      post   :add_tags
      delete :remove_tag
      put    :change_tags
      put    :lock
      put    :unlock
      get    :repost
    end
    collection do
      get :friends
      get :newest
      get :recommend
      get :joined
      get :favs
      get :hidden
      get :no_reply
      get :search
      get :incoming
      get :public_timeline
    end
  end

  post '/feeds/:feed_id/comments' => 'post_comments#create'
  resources :post_comments do
    collection do
      post :reply
    end
  end
end

def match_channels_routes
  resources :channels do
    collection do
      get :fb_orderlist 
      put :sort
      get :none
    end
    member do
      put :add
      put :remove
      get :new_blog_post
      post :add_users
      get :newest_feed_ids
    end
  end
end

def match_tags_routes
  resources :tags do
    member do
      put :logo
      get :upload_logo
      get :atom
      get :aj_info
      post :fav
      delete :unfav
      put :update_detail
    end
    resources :tag_detail_revisions,:path=>"revisions"
  end
  resources :tag_detail_revisions do
    member do
      put :rollback
    end
  end
end

def match_collections_routes
  resources :collections do
    member do
      put  :change_name
      put :change_sendto
      put :add_feed
    end
  end
end

def match_photos_and_entries_routes
  post '/photos/upload_for_feed' => 'photos#upload_for_feed'
  post '/photos/import_image_url'=> 'photos#import_image_url'
end

def match_tsina_app_routes
  namespace(:apps) do
    get 'tsina/mindpin'              => 'tsina_app_mindpin#index'
    get 'tsina/mindpin/connect'      => 'tsina_app_mindpin#connect'
    get 'tsina/mindpin/callback'     => 'tsina_app_mindpin#callback'

    get 'tsina/tu'                   => 'tsina_app_tu#index'
    get 'tsina/tu/connect'           => 'tsina_app_tu#connect'
    get 'tsina/tu/callback'          => 'tsina_app_tu#callback'

    get 'tsina/schedule'             => 'tsina_app_schedule#index'
    get 'tsina/schedule/connect'     => 'tsina_app_schedule#connect'
    get 'tsina/schedule/callback'    => 'tsina_app_schedule#callback'
  end
end

def match_weibo_routes
  namespace :web_weibo, :path=>'weibo' do
    get '/'                           => 'timeline#home_timeline'  # 微博首页
    get '/users/:uid'                 => 'timeline#user_timeline'  # 某用户的微博
    get '/trends/:trend_name'         =>  'timeline#trend_statuses'

    get   '/atmes'         => 'timeline#atmes'          # @我的
    get   '/comments/byme' => 'timeline#comments_by_me' # 我发出的评论
    get   '/comments/tome' => 'timeline#comments_to_me' # 我收到的评论

    get   '/contacts/:uid/friends'   => 'contacts#friends'   #某用户的关注对象
    get   '/contacts/:uid/followers' => 'contacts#followers' #某用户的粉丝

    get   '/statuses/:mid'             => 'statuses#show'        # 单条微博显示
    post  '/statuses'                  => 'statuses#create'      # 发一条微博
    post  '/statuses/:mid/add_comment' => 'statuses#add_comment' # 发一条评论

    get  '/unread'                    => 'statuses#unread' # 获取当前的未读微博数

    get  '/cart'     => 'cart#index'
    post '/cart/add' => 'cart#add'
  end
end

def match_douban_routes
  namespace :web_douban, :path=>'douban' do
    get  '/' => 'events#index'
  end
end

######################################

Mindpin::Application.routes.draw do
  # ---------------- 首页和欢迎页面 ---------
  root :to => 'index#index'
  
  match_auth_routes
  match_login_wallpaper_routes
  
  match_forgot_password_routes
  match_account_routes
  match_connect_tsina_routes
  match_activation_routes
  
  match_user_routes
  match_feeds_routes

  get '/short_url/:code'        => 'short_urls#show'
  match_channels_routes
  match_tags_routes

  resources :atmes

  match_collections_routes

  match_photos_and_entries_routes

  match_tsina_app_routes

  resources :notices do
    collection do
      get :common
      get :invites
    end
  end

  resources :post_drafts

  get '/:user_id/contacts'          => 'contacts#index'
  get '/:user_id/feeds'             => 'feeds#index'
  get '/:user_id/collections'       => 'collections#index'

  namespace(:api0) do
    # ---------------- 手机客户端同步数据 ----------
    get 'mobile_data_syn'  => 'api#mobile_data_syn'
    get 'home_timeline'    => 'api#home_timeline'

    # 收集册 collections
    get    'collections/feeds'  => 'api#collection_feeds'
    get    'collections/list'   => 'api#collection_list'
    post   'collections/create' => 'api#create_collection'
    delete 'collections/delete' => 'api#delete_collection'
    put    'collections/rename' => 'api#rename_collection'

    # 主题 feeds
    get  'feeds/show'               => 'api#show'
    post 'feeds/create'             => 'api#create'
    post 'feeds/upload_photo'       => 'api#upload_photo'

    # 主题评论 comments

    get    'comments/list'   => 'api#feed_comments'
    post   'comments/create' => 'api#create_comment'
    delete 'comments/delete' => 'api#delete_comment'
    post   'comments/reply'  => 'api#reply_comment'

    get    'comments/received' => 'api#comments_received'
    get    'comments/sent'     => 'api#comments_sent'

    # 人际关系 contacts
    get 'contacts/followings' => 'api#contacts_followings'
    get 'test' => "api#test"
  end


  match_weibo_routes
  match_douban_routes
    
  namespace(:admin) do
    resources :apply_records
  end
end
