ActionController::Routing::Routes.draw do |map|
  map.root :controller=>"workspaces"

  map.resources :workspaces,:collection=>{:list=>:get} do |workspace|
    workspace.resources :file_entries
    workspace.resources :memberships,
      :collection=>{:add_members_form=>:get,:add_members=>:post,:invite_members_form=>:get,:invite_members=>:post,
      :quit=>:get,:join=>:get,:apply_join=>:post,:members_manage=>:get},
      :member=>{:approve=>:put,:refuse=>:put,:kick_out=>:put,:ban=>:put,:unban=>:put}
  end
  
  map.resources :memberships
  map.resources :file_entries,:member=>{:upload=>:get}
end