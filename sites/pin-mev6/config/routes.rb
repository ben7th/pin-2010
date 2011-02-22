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
  map.resources :mindmaps,:member=>{:export=>:get} do |mindmap|

    mindmap.files                   "files",:controller=>"files",:action=>"index",:conditions=>{:method=>:get}
    mindmap.search_image            "files/search_image",:controller=>"files",:action=>"search_image",:conditions=>{:method=>:get}
    mindmap.show_image_editor       "files/i_editor",:controller=>'files',:action=>'show_image_editor',:conditions=>{:method=>:get}

    mindmap.upload_web_file         "upload_web_file",:controller=>"files",:action=>"upload_web_file",:conditions=>{:method=>:post}
    mindmap.upload_file             "upload_file",:controller=>"files",:action=>"upload_file",:conditions=>{:method=>:post}

    mindmap.show_upload_file        "files/*path",:controller=>"files",:action=>"show_upload_file",:conditions=>{:method=>:get}
    mindmap.show_upload_file_thumb  "thumb/*path",:controller=>"files",:action=>"show_upload_file_thumb",:conditions=>{:method=>:get}

    mindmap.delete_upload_file      "files/*path",:controller=>"files",:action=>"destroy",:conditions=>{:method=>:delete}
  end
end
