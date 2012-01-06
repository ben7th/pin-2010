Mindpin::Application.routes.draw do
  # ---------------- 首页和欢迎页面 ---------
  root :to => 'index#index'
  get '/login' => 'index#index'
  
  get '/publics' => 'index#public_maps'
  get '/favs'    => 'index#fav_maps'
  
  get '/search'  => 'search#index'

  resources :users
  resources :image_attachments

  get  '/new'           => 'builder#new'            # 普通新建表单
  get  '/import'        => 'builder#import'         # 导入表单
  post '/import_upload' => 'builder#import_upload'  # 上传原始文件
  post '/create'        => 'builder#create'         # 普通创建和导入创建都提交到这个action

  resources :mindmaps do
    member do
      put :toggle_private
      get :info
      put :toggle_fav
      put :undo
      put :redo
      put :refresh_thumb
    end
    get 'files'              => 'files#index'
    get 'files/search_image' => 'files#search_image'
    get 'files/i_editor'     => 'files#show_image_editor'
    get 'files/f_editor'     => 'files#show_font_editor'
  end

end
