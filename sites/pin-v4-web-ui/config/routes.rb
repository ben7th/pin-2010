
ActionController::Routing::Routes.draw do |map|
  
  map.root :controller=>'index'
  map.welcome '/welcome',:controller=>'index',:action=>'welcome'
  
  # ---------------- 功能演示 ---------------
  map.namespace :demo do |demo|
    demo.root :controller=>'index',:action=>'index'
    demo.d '/workspace',:controller=>'index',:action=>'workspace'
    demo.d '/discuss',:controller=>'index',:action=>'discuss'
    demo.d '/group',:controller=>'index',:action=>'group'
    demo.d '/repo',:controller=>'index',:action=>'repo'
    demo.d '/attach',:controller=>'index',:action=>'attach'
    demo.d '/widget',:controller=>'index',:action=>'widget'
  end
  
  # ---------------- Pie Ui Demo ---------------
  map.namespace :'pieui' do |pie|
    pie.root :controller=>'index',:action=>'index'
    pie.ui '/list',:controller=>'index',:action=>'list'
    pie.ui '/list/:name',:controller=>'index',:action=>'list'
  end

  # ---------------- 用户认证相关 -----------

  map.login '/login',:controller=>'sessions',:action=>'new'
  map.logout '/logout',:controller=>'sessions',:action=>'destroy'
  map.signup '/signup',:controller=>'users',:action=>'new'

  map.collector '/collector',:controller=>'collector',:action=>'new'
  map.collector_create '/collectors',:controller=>'collector',:action=>'create'

end
