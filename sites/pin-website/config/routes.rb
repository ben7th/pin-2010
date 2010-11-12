ActionController::Routing::Routes.draw do |map|
  map.root :controller=>"web_sites"
  map.resources :comments
  map.resources :web_sites do |web_site|
    web_site.resource :feeling
    web_site.resources :introductions
    web_site.resources :comments
  end

  map.resources :browse_histories

  map.namespace :sidebar do |sidebar|
    sidebar.resources :comments
  end
  
  map.sidebar_web_site_info "sidebar/web_site_infos",:controller=>"sidebar/web_site_infos",:action=>"show"

  map.sidebar_browse_histories_infos "sidebar/browse_histories_infos",:controller=>"sidebar/browse_histories_infos",:action=>"index"
  map.more_sidebar_browse_histories_infos "sidebar/more_browse_histories_infos",:controller=>"sidebar/browse_histories_infos",:action=>"more"
  map.one_sidebar_browse_histories_infos "sidebar/one_browse_histories_infos",:controller=>"sidebar/browse_histories_infos",:action=>"one_page"

  map.sidebar_web_site_detail_info "sidebar/web_site_detail_infos",:controller=>"sidebar/web_site_infos",:action=>"show_detail"


end
