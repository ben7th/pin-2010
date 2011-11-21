ActionController::Routing::Routes.draw do |map|
  map.root :controller=>'index',:action=>'index'
  map.resources :course_items,:member=>{
    :select=>:post,:cancel_select=>:delete
  }

  map.resource :profile
  map.resources :teachers

  map.resources :users
end
