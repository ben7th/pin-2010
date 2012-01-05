Mindpin::Application.routes.draw do
  # ---------------- 首页和欢迎页面 ---------
  root :to => 'index#index'
  
  get '/login' => 'index#index'

  resources :users
  resources :image_attachments

  get '/mindmaps/public' => 'mindmaps#public_maps'
  get '/mindmaps/users/:user_id' => 'mindmaps#user_mindmaps'
  get '/mindmaps/import_file_thumb/:upload_temp_id/thumb.png' => 'mindmaps#import_file_thumb'

  resources :mindmaps do
    collection do
      get  :cooperates
      get  :search
      get  :import
      post :do_import
      post :upload_import_file
      get  :favs
    end
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
