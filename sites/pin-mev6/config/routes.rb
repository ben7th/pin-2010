ActionController::Routing::Routes.draw do |map|
  
  map.root :controller=>"index",:action=>'index'
  map.login '/login',:controller=>"index",:action=>'index'

  ################### 用户设置
  # 基本信息
  map.user_base_info "/account",:controller=>"account",:action=>"base",:conditions=>{:method=>:get}
  map.user_base_info_submit "/account",:controller=>"account",:action=>"base_submit",:conditions=>{:method=>:put}
  # 头像设置
  map.user_avatared_info "/account/avatared",:controller=>"account",:action=>"avatared",:conditions=>{:method=>:get}
  map.user_avatared_info_submit "/account/avatared",:controller=>"account",:action=>"avatared_submit",:conditions=>{:method=>:put}


  map.public_maps "/mindmaps/public",:controller=>"mindmaps",:action=>"public_maps"
  map.user_mindmaps "/mindmaps/users/:user_id",:controller=>"mindmaps",:action=>"user_mindmaps"

  map.resources :mindmaps,:collection=>{
    :aj_words=>:get,
    :cooperates=>:get,
    :search=>:get,
    :import=>:get,
    :do_import=>:post,
    :upload_import_file=>:post,
    :favs=>:get
  },:member=>{
    :export=>:get,
    :change_title=>:put,
    :clone_form=>:get,
    :do_clone=>:put,
    :toggle_private=>:put,
    :info=>:get,
    :toggle_fav=>:put,
    :comments=>:post,
    :newest=>:get,
    :widget=>:get,
    :undo=>:put,
    :redo=>:put,
    :rollback_history_record=>:put,
    :history_records=>:get,
    :share_original=>:put
  } do |mindmap|
    mindmap.files                   "files",:controller=>"files",:action=>"index",:conditions=>{:method=>:get}
    mindmap.search_image            "files/search_image",:controller=>"files",:action=>"search_image",:conditions=>{:method=>:get}
    mindmap.show_image_editor       "files/i_editor",:controller=>'files',:action=>'show_image_editor',:conditions=>{:method=>:get}
    mindmap.show_font_editor        "files/f_editor",:controller=>'files',:action=>'show_font_editor',:conditions=>{:method=>:get}

    mindmap.resources :comments,:controller=>"comments"
  end
  map.resources :comments,:controller=>"comments"

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

  # 新浪微博 app
  map.connect "/tsina_app",:controller=>"tsina_app",:action=>"index"
  map.connect "/tsina_app/connect",:controller=>"tsina_app",:action=>"connect"
  map.connect "/tsina_app/connect_callback",:controller=>"tsina_app",:action=>"connect_callback"
  map.connect "/tsina_app/create_mindmap",:controller=>"tsina_app",
    :action=>"create_mindmap",:conditions=>{:method=>:post}
  map.connect "/tsina_app/mindmaps",:controller=>"tsina_app",:action=>"mindmaps"
  map.connect "/tsina_app/mindmaps/:id/edit",:controller=>"tsina_app",:action=>"edit"
end
