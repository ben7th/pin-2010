Mindpin::Application.routes.draw do
  root :to => 'index#index'
  
  resources :course_items do
    member do
      post   :select
      delete :cancel_select
    end
  end

  resource :profile
  resources :teachers
  resources :users

  get '/teamtodo' => 'teamtodo#index'
end
