ActionController::Routing::Routes.draw do |map|
  map.root :controller=>'index'

  map.search '/search',:controller=>'index',:action=>'search'

  map.resources :users do |user|
    user.resources :mindmaps,:collection=>{:recently=>:get,:pie_links=>:get}
    user.resource :tendency
  end

  map.resources :messages

  map.mindmap_do '/mindmaps/do',:controller=>'mindmaps',:action=>'save_operation_record'
  map.mindmap_tag '/mindmaps/tag/:tag_name',:controller=>'mindmaps',:action=>'get_mindmap_by_tag'
  map.mindmap_user_tag '/users/:user_id/mindmaps/tag/:tag_name',:controller=>'mindmaps',:action=>'get_mindmap_by_tag'

  map.resources :mindmaps,:collection=>{:import=>:get,:mine=>:get,:tags=>:get,:import_base64=>:post,:create_base64=>:post},
    :member=>{:convert_bundle=>:put,:toggle_private=>:put,
      :export=>:get,:clone_form=>:get,:clone=>:put,
      :outline=>:get,:rate=>:put,:setnote=>:post,:paramsedit=>:get,
      :widget=>:get,:quote=>:get,:reimport=>:get,:neweditor=>:get
    } do |mindmap|
      mindmap.resources :comments
      mindmap.resources :snapshots,:member=>{:recover=>:put}
    end

  # MindPin功能说明和帮助
  map.intro_mindmap '/intro/mindmap',:controller=>'help',:action=>'intro_mindmap'
  map.intro_editor '/intro/editor',:controller=>'help',:action=>'intro_editor'
  map.intro_mapimport '/intro/mapimport',:controller=>'help',:action=>'intro_mapimport'

  map.help '/help',:controller=>'help',:action=>'index'
  # 在线动态演示
  map.mapdemo '/mapdemo',:controller=>'help',:action=>'mapdemo'

  map.resources :thumbs

  # -----------  获取信息类API 开始  -----------
  # 获取用户个人导图列表
  map.current_user_maps "/api/user_maps.:format",:controller=>"api",:action=>"current_user_maps",:conditions=>{:method=>:get}
  map.user_maps "/api/user_maps/:id.:format",:controller=>"api",:action=>"user_maps",:conditions=>{:method=>:get},:requirements => { :id => /\w+/}
  # 获取单个导图信息
  map.show_map "/api/show/:id.:format",:controller=>"api",:action=>"show",:conditions=>{:method=>:get},:requirements => { :id => /\w+/ }
  # 导出导图为其他软件格式
  map.export_map "/api/export/:id.:format",:controller=>"api",:action=>"export",:conditions=>{:method=>:get},:requirements => { :id => /\w+/ }
  # 导出导图为图片
  map.image_map "/api/image/:id.:format",:controller=>"api",:action=>"image",:conditions=>{:method=>:get},:requirements => { :id => /\w+/ }
  # -----------  获取信息类API 结束  ------------------


  # -----------  导图管理类API 开始 -----------
  # 创建一个导图
  map.create_map "/api/create",:controller=>"api",:action=>"create",:conditions=>{:method=>:post}
  # 删除一个导图
  map.destroy_map "/api/destroy/:id",:controller=>"api",:action=>"destroy",:conditions=>{:method=>:delete},:requirements => { :id => /\w+/ }
  # -----------  导图管理类API 结束 -----------


  # -----------  导图操作类API 开始  -----------
  # 插入一个节点
  map.do_insert "/api/do_insert/:id",:controller=>"api",:action=>"do_insert",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 删除一个节点
  map.do_delete "/api/do_delete/:id",:controller=>"api",:action=>"do_delete",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 修改一个节点标题
  map.do_title "/api/do_title/:id",:controller=>"api",:action=>"do_title",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 折叠/展开一个节点
  map.do_toggle "/api/do_toggle/:id",:controller=>"api",:action=>"do_toggle",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 在一个节点上插入图片
  map.do_image "/api/do_image/:id",:controller=>"api",:action=>"do_image",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 移动一个节点
  map.do_move "/api/do_move/:id",:controller=>"api",:action=>"do_move",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 给一个节点插入备注
  map.do_note "/api/do_note/:id",:controller=>"api",:action=>"do_note",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 修改一个节点的颜色
  map.do_change_color "/api/do_change_color/:id",:controller=>"api",:action=>"do_change_color",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 给一个节点增加链接
  map.do_add_link "/api/do_add_link/:id",:controller=>"api",:action=>"do_add_link",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 修改一个节点的字体大小
  map.do_change_font_size "/api/do_change_font_size/:id",:controller=>"api",:action=>"do_change_font_size",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 修改节点文字是否为粗体字
  map.do_set_font_bold "/api/do_set_font_bold/:id",:controller=>"api",:action=>"do_set_font_bold",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # 修改节点文字是否为斜体字
  map.do_set_font_italic "/api/do_set_font_italic/:id",:controller=>"api",:action=>"do_set_font_italic",:conditions=>{:method=>:put},:requirements => { :id => /\w+/ }
  # -----------  导图操作类API 结束  -----------

  map.bundle_to_mindmap "/mindmaps/bundles",:controller=>"bundles",:action=>"create",:conditions=>{:method=>:post}
end
