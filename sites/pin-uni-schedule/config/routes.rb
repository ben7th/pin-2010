ActionController::Routing::Routes.draw do |map|
  map.root :controller=>'index',:action=>'index'
  map.resources :course_items,:member=>{
    :select=>:post,:cancel_select=>:delete
  }

  map.resources :users
  map.resource :profile
end
