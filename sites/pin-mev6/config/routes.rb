Mindpin::Application.routes.draw do
  # ---------------- 首页和欢迎页面 ---------
  root :to => 'index#index'
  get '/login' => 'index#index'
  
  get '/publics' => 'index#public_maps'
  get '/favs'    => 'index#fav_maps'
  
  get '/search'  => 'search#index'

  resources :users
  resources :image_attachments

  post '/create' => 'builder#create'  # 普通创建
  post '/import' => 'builder#import'  # 导入

  put '/v6/save'             => 'v6/editor#save'
  get '/v6/:mindmap_id'      => 'v6/editor#index'
  get '/v6/:mindmap_id/edit' => 'v6/editor#edit'
  get '/v6/:mindmap_id/view' => 'v6/editor#view'
  
  put '/v7/save'             => 'v7/editor#save'
  get '/v7/:mindmap_id'      => 'v7/editor#index'
  get '/v7/:mindmap_id/edit' => 'v7/editor#edit'
  get '/v7/:mindmap_id/view' => 'v7/editor#view'

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

  # others...
  get '/about' => 'help#about'

end
