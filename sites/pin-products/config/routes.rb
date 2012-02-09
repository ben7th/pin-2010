Mindpin::Application.routes.draw do
  root :to => 'products#index'
  resources :products do
    member do
      get :edit_server_develop_description
      get :edit_web_ui_develop_description
      get :edit_mobile_client_develop_description
      get :edit_deploy_description
      get :edit_difficulty
      
      put :update_server_develop_description
      put :update_web_ui_develop_description
      put :update_mobile_client_develop_description
      put :update_deploy_description
      put :update_difficulty
    end
    resources :issues
  end
  resources :issues do
    member do
      put :done
    end
    resources :issue_comments
  end
  resources :issue_comments do
    member do
      get :reply
      post :do_reply
    end
  end
end
