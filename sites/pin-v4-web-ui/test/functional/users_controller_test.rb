require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "用户注册测试" do
   
    get :new # 进入用户注册页面，也就是路由中的signup
    assert_response :success
    assert_difference("User.count",1) do
      post :create,:user=>{:name=>"中国人",
        :password=>"123456",:password_confirmation=>"123456",
        :email=>"123@165.com"}
    end
    china_ren = User.last
    assert_equal china_ren.name, "中国人"
    assert_equal china_ren.email, "123@165.com"
    # 重复注册，会出现错误
    assert_difference("User.count",0) do
      post :create,:user=>{:name=>"中国人",
        :password=>"123456",:password_confirmation=>"123456",
        :email=>"123@165.com"}
    end
    # 电子邮箱不正确，失败
    assert_difference("User.count",0) do
      post :create,:user=>{:name=>"中国人",
        :password=>"123456",:password_confirmation=>"123456",
        :email=>"123165.com"}
    end
    # 姓名不正确，失败
    assert_difference("User.count",0) do
      post :create,:user=>{:name=>"中国人",
        :password=>"123456",:password_confirmation=>"123456",
        :email=>"123@165.com"}
    end
    # 两次输入的密码不一样
    assert_difference("User.count",0) do
      post :create,:user=>{:name=>"中国人",
        :password=>"123678",:password_confirmation=>"123456",
        :email=>"123@165.com"}
    end
  end

end
