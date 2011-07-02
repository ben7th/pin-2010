ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #  map.connect ':controller/:action/:id'
  #  map.connect ':controller/:action/:id.:format'


  map.root :controller => "index"

  #################### 用户登录
  map.login '/login',:controller=>'sessions',:action=>'new'
  map.logout '/logout',:controller=>'sessions',:action=>'destroy'
  map.resource :session

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
    :import_file=>:post,
    :aj_words=>:get,
    :cooperates=>:get,
    :search=>:get,
    :import=>:get
  },:member=>{
    :export=>:get,
    :change_title=>:put,
    :clone_form=>:get,
    :do_clone=>:put,
    :do_private=>:put,
    :info=>:get,
    :fav=>:post,
    :unfav=>:delete,
    :comments=>:post,
    :newest=>:get
  } do |mindmap|
    mindmap.files                   "files",:controller=>"files",:action=>"index",:conditions=>{:method=>:get}
    mindmap.search_image            "files/search_image",:controller=>"files",:action=>"search_image",:conditions=>{:method=>:get}
    mindmap.show_image_editor       "files/i_editor",:controller=>'files',:action=>'show_image_editor',:conditions=>{:method=>:get}
    mindmap.show_font_editor        "files/f_editor",:controller=>'files',:action=>'show_font_editor',:conditions=>{:method=>:get}

    mindmap.upload_web_file         "upload_web_file",:controller=>"files",:action=>"upload_web_file",:conditions=>{:method=>:post}
    mindmap.upload_file             "upload_file",:controller=>"files",:action=>"upload_file",:conditions=>{:method=>:post}

    mindmap.show_upload_file        "files/*path",:controller=>"files",:action=>"show_upload_file",:conditions=>{:method=>:get}
    mindmap.show_upload_file_thumb  "thumb/*path",:controller=>"files",:action=>"show_upload_file_thumb",:conditions=>{:method=>:get}

    mindmap.delete_upload_file      "files/*path",:controller=>"files",:action=>"destroy",:conditions=>{:method=>:delete}
    mindmap.resources :comments,:controller=>"comments"
  end

  map.resources :users
end
