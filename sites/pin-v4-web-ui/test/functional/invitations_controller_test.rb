require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase
  test "不允许重复对一个邮箱发出多次邀请" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    assert_difference("Invitation.count",1) do
      post "create",:invitation=>{:contact_email=>"nobody@gmail.com"}
    end
    assert_difference("Invitation.count",0) do
      post "create",:invitation=>{:contact_email=>"nobody@gmail.com"}
    end
  end

  test "不能邀请自己" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    assert_difference("Invitation.count",0) do
      post "create",:invitation=>{:contact_email=>lifei.email}
    end
  end

  test "不能邀请已注册用户" do
    lifei = users(:lifei)
    songliang = users(:songliang)
    session[:user_id] = lifei.id
    assert_difference("Invitation.count",0) do
      post "create",:invitation=>{:contact_email=>songliang.email}
    end
  end
end