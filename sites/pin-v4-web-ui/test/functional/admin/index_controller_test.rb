require 'test_helper'

class Admin::IndexControllerTest < ActionController::TestCase

  test "非管理员不能访问管理员主页" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    get :index
    assert_response 403
  end

  test "管理员访问管理员主页" do
    admin = users(:admin)
    session[:user_id] = admin.id
    get :index
    assert_response :success
  end
  
end
