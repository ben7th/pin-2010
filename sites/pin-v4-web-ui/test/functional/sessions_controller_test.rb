require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "用户正确登录" do
    # 夹具中读取用户lifei，他的用户名是：lifei，email是：fushang318@163.com，密码是123456
    lifei = users(:lifei)
    post :create,:email=>lifei.email,:password=>"123456"
    assert_redirected_to '/'
    assert_equal session[:user_id],lifei.id
  end

  test "用户输入的密码错误" do
    # 如果输入的密码不正确则跳转到登录页面
    post :create,:email=>"fushang318@163.com",:password=>"123"
    #assert_redirected_to :action=>:new
    assert session[:user_id].blank?
  end

  test "用户登录的login错误" do
    # 如果输入的login不正确则跳转到登录页面
    post :create,:email=>"fu318@163.com",:password=>"123456"
    #assert_redirected_to :action=>:new
    assert session[:user_id].blank?
  end

end
