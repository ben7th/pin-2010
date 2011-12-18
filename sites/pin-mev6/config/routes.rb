include RoutesMethods

ActionController::Routing::Routes.draw do |map|
  map.root :controller=>"index",:action=>'index'
  map.login '/login',:controller=>"index",:action=>'index'

  map.public_maps "/mindmaps/public",:controller=>"mindmaps",:action=>"public_maps"
  map.user_mindmaps "/mindmaps/users/:user_id",:controller=>"mindmaps",:action=>"user_mindmaps"

  match_get map, '/tsina_app' => 'index#tsina_app_redirect'

  map.resources :mindmaps,:collection=>{
    :aj_words           => :get,
    :cooperates         => :get,
    :search             => :get,
    :import             => :get,
    :do_import          => :post,
    :upload_import_file => :post,
    :favs               => :get,
    :mine_private       => :get
  },:member=>{
    :export                  => :get,
    :change_title            => :put,
    :clone_form              => :get,
    :do_clone                => :put,
    :toggle_private          => :put,
    :info                    => :get,
    :toggle_fav              => :put,
    :newest                  => :get,
    :widget                  => :get,
    :undo                    => :put,
    :redo                    => :put,
    :rollback_history_record => :put,
    :history_records         => :get,
    :share_original          => :put,
    :refresh_thumb           => :put
  } do |mindmap|
    mindmap.files                   "files",:controller=>"files",:action=>"index",:conditions=>{:method=>:get}
    mindmap.search_image            "files/search_image",:controller=>"files",:action=>"search_image",:conditions=>{:method=>:get}
    mindmap.show_image_editor       "files/i_editor",:controller=>'files',:action=>'show_image_editor',:conditions=>{:method=>:get}
    mindmap.show_font_editor        "files/f_editor",:controller=>'files',:action=>'show_font_editor',:conditions=>{:method=>:get}
  end

  # 导图协同
  map.add_cooperator "/cooperate/:mindmap_id/add_cooperator",
    :controller=>"cooperations",:action=>"add_cooperator",
    :conditions=>{:method=>:post}
  map.remove_cooperator "/cooperate/:mindmap_id/remove_cooperator",
    :controller=>"cooperations",:action=>"remove_cooperator",
    :conditions=>{:method=>:delete}

  map.connect "/mindmaps/import_file_thumb/:upload_temp_id/thumb.png",
    :controller=>"mindmaps",:action=>"import_file_thumb"

  map.resources :users
  map.resources :image_attachments
  map.resources :atmes

end
