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
  map.root :controller => "index"
  map.operate_project "operate_project", :controller=>"index",:action=>"operate_project",:conditions=>{:method=>:post}
  map.operate_server "operate_server", :controller=>"index",:action=>"operate_server",:conditions=>{:method=>:post}
  map.operate_worker "operate_worker", :controller=>"index",:action=>"operate_worker",:conditions=>{:method=>:post}
  map.operate_resque_queue_worker "operate_resque_queue_worker",
    :controller=>"index",:action=>"operate_resque_queue_worker",
    :conditions=>{:method=>:post}


  map.memcached_stats "memcached_stats", :controller=>"index",:action=>"memcached_stats",:conditions=>{:method=>:get}

  map.redis_stats_path "redis_stats", :controller=>"index",:action=>"redis_stats",:conditions=>{:method=>:get}
  map.redis_flushall_path "redis_flushall", :controller=>"index",:action=>"redis_flushall",:conditions=>{:method=>:post}

  map.redis_cache_flush_path "redis_cache_flush", :controller=>"index",:action=>"redis_cache_flush",:conditions=>{:method=>:post}
  map.redis_tip_flush_path "redis_tip_flush", :controller=>"index",:action=>"redis_tip_flush",:conditions=>{:method=>:post}
  map.redis_queue_flush_path "redis_queue_flush", :controller=>"index",:action=>"redis_queue_flush",:conditions=>{:method=>:post}

  map.project_log "project_log", :controller=>"index",:action=>"project_log",:conditions=>{:method=>:get}
  map.server_log "server_log", :controller=>"index",:action=>"server_log",:conditions=>{:method=>:get}
  map.worker_log "worker_log", :controller=>"index",:action=>"worker_log",:conditions=>{:method=>:get}
  map.resque_queue_worker_log "resque_queue_worker_log",:controller=>"index",
    :action=>"resque_queue_worker_log",:conditions=>{:method=>:get}

  map.login "/login",:controller => "index",:action=>"login"
  map.login "/do_login",:controller => "index",:action=>"do_login",:conditions=>{:method=>:post}
  map.login "/logout",:controller => "index",:action=>"logout"
end
