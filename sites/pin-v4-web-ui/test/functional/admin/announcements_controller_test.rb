require 'test_helper'

class Admin::AnnouncementsControllerTest < ActionController::TestCase

  test "非管理员不能操作公告" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    get :index
    assert_response 403
    get :new
    assert_response 403
    assert_difference("Announcement.count",0) do
      post :create,:announcement=>{:content=>"s公告"}
      assert_response 403
    end
    annoucement = Announcement.create(:content=>"公告")
    get :edit,:id=>annoucement.id
    assert_response 403
    put :update,:id=>annoucement.id,:annoucement=>{:content=>"哈哈"}
    assert_response 403
    assert_difference("Announcement.count",0) do
      delete :destroy,:id=>annoucement.id
      assert_response 403
    end
  end

  test "管理员发表公告" do
    admin = users(:admin)
    session[:user_id] = admin.id
    get :new
    assert_response :success
    assert_difference("Announcement.count",1) do
      post :create,:announcement=>{:content=>"公告，很好"}
    end
    annoucement = Announcement.last
    assert_equal annoucement.content,"公告，很好"
    get :edit,:id=>annoucement.id
    assert_response :success
    put :update,:id=>annoucement.id,:announcement=>{:content=>"公告"}
    annoucement.reload
    assert annoucement.content,"公告"
    assert_difference("Announcement.count",-1) do
      delete :destroy,:id=>annoucement.id
    end
  end
  
end
