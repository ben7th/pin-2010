ActionController::Routing::Routes.draw do |map|
  map.root :controller=>'index'

  map.search '/search.:format',:controller=>'index',:action=>'search'

  map.resources :users,:member=>{:cooperate=>:get} do |user|
    user.resources :mindmaps,:collection=>{:recently=>:get,:pie_links=>:get}
    user.resource :tendency
  end

  map.mindmap_do '/mindmaps/do',:controller=>'mindmaps',:action=>'save_operation_record'

  map.resources :mindmaps,:collection=>{:import=>:get,:mine=>:get,:tags=>:get,:import_base64=>:post,:create_base64=>:post},
    :member=>{:convert_bundle=>:put,:toggle_private=>:put,
      :export=>:get,:clone_form=>:get,:do_clone=>:put,
      :outline=>:get,:rate=>:put,:setnote=>:post,:paramsedit=>:get,
      :widget=>:get,:quote=>:get,:reimport=>:get,:neweditor=>:get,
      :upload_web_file=>:post,:upload_file=>:post
    } do |mindmap|
      mindmap.resources :comments
      mindmap.resources :snapshots,:member=>{:recover=>:put}
    end

  map.show_upload_file        "/mindmaps/:id/files/*path",:controller=>"mindmaps",:action=>"show_upload_file"
  map.show_upload_file_thumb  "/mindmaps/:id/thumb/*path",:controller=>"mindmaps",:action=>"show_upload_file_thumb"

  map.cooperate_dialog "/cooperate/:mindmap_id",:controller=>"cooperations",:action=>"cooperate_dialog",:conditions=>{:method=>:get}

  map.save_cooperations "/save_cooperations/:mindmap_id",:controller=>"cooperations",:action=>"save_cooperations",:conditions=>{:method=>:post}


  map.resources :organizations do |org|
    org.resources :mindmaps,:collection=>{:import=>:get},:controller=>"organization_mindmaps"
  end

  map.resources :thumbs
end
