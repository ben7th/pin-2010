ActionController::Routing::Routes.draw do |map|
  map.root :controller => "notes",:action=>"new"
  map.resources :notes,:collection=>{:add_another=>:get},:member=>{:download=>:get} do |note|
    note.resources :comments
    note.commit '/commits/:commit_id',:controller=>'notes',:action=>'show'
    note.commit_download '/download/:commit_id',:controller=>'notes',:action=>'download'
    note.raw "/raw/:blob_id/*file_name",:controller=>'notes',:action=>'raw'
  end
  map.resources :comments

  map.star_note "/star/:note_id",:controller=>"stars",:action=>"create",:conditions => { :method => :post }
  map.unstar_note "/unstar/:note_id",:controller=>"stars",:action=>"destroy",:conditions => { :method => :delete }

  map.starred_notes "/starred",:controller=>"stars",:action=>"index",:conditions => { :method => :get }

  map.upload_page "/upload_page/:note_id",:controller=>"notes",:action=>"upload_page",:conditions => { :method => :get }
  map.upload_page "/upload/:note_id",:controller=>"notes",:action=>"upload",:conditions => { :method => :post }

end
