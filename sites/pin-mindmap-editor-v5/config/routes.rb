ActionController::Routing::Routes.draw do |map|
  # index_controller
  map.root :controller=>'index'
  map.search '/search.:format',:controller=>'index',:action=>'search'

  # users_controller
  # user_mindmaps_controller
  # tendencies_controller
  map.resources :users,:member=>{:cooperate=>:get} do |user|
    user.resources :mindmaps,:controller=>'user_mindmaps'
    user.resource :tendency
  end

  map.mindmap_do '/mindmaps/do',:controller=>'mindmaps',:action=>'save_operation_record'

  map.resources :mindmaps,
    :collection=>{
      :import=>:get,
      :create_base64=>:post, # 浏览器插件用到
      :import_base64=>:post  # 浏览器插件用到
    },
    :member=>{
      :paramsedit=>:get,
      :export=>:get,
      :clone_form=>:get,
      :do_clone=>:put,
    } do |mindmap|
      mindmap.resources :comments
      mindmap.resources :snapshots,:member=>{:recover=>:put}
      
      mindmap.files                   "files",:controller=>"files",:action=>"index",:conditions=>{:method=>:get}
      mindmap.search_image            "files/search_image",:controller=>"files",:action=>"search_image",:conditions=>{:method=>:get}
      mindmap.show_image_editor       "files/i_editor",:controller=>'files',:action=>'show_image_editor',:conditions=>{:method=>:get}

      mindmap.upload_web_file         "upload_web_file",:controller=>"files",:action=>"upload_web_file",:conditions=>{:method=>:post}
      mindmap.upload_file             "upload_file",:controller=>"files",:action=>"upload_file",:conditions=>{:method=>:post}

      mindmap.show_upload_file        "files/*path",:controller=>"files",:action=>"show_upload_file",:conditions=>{:method=>:get}
      mindmap.show_upload_file_thumb  "thumb/*path",:controller=>"files",:action=>"show_upload_file_thumb",:conditions=>{:method=>:get}

      mindmap.delete_upload_file      "files/*path",:controller=>"files",:action=>"destroy",:conditions=>{:method=>:delete}

    end


  #cooperations_controller
  map.cooperate_dialog "/cooperate/:mindmap_id",:controller=>"cooperations",:action=>"cooperate_dialog",:conditions=>{:method=>:get}
  map.save_cooperations "/save_cooperations/:mindmap_id",:controller=>"cooperations",:action=>"save_cooperations",:conditions=>{:method=>:post}


  #organizations_controller
  map.resources :organizations do |org|
    org.resources :mindmaps,:collection=>{:import=>:get},:controller=>"organization_mindmaps"
  end
end
