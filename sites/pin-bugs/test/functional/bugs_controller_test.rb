require 'test_helper'

class BugsControllerTest < ActionController::TestCase

  test "登录提交一个bug" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    get :new
    assert_response :success
    content = "BUG内容 blan blan"
    assert_difference("Bug.count",1) do
      post :create,:bug=>{:kind=>Bug::ERROR,:content=>content,:attachment=>File.new("#{RAILS_ROOT}/test/upload_files/1.wma")}
    end
    bug = Bug.last
    assert_equal bug.kind,Bug::ERROR
    assert_equal bug.content,content
    assert_equal bug.user,lifei
    assert_equal bug.user_ip,nil
  end

  test "不登录提交一个bug" do
    get :new
    assert_response :success
    content = "BUG内容 blan blan"
    assert_difference("Bug.count",1) do
      post :create,:bug=>{:kind=>Bug::PROPOSITION,:content=>content}
    end
    bug = Bug.last
    assert_equal bug.kind,Bug::PROPOSITION
    assert_equal bug.content,content
    assert_equal "0.0.0.0",bug.user_ip
    assert_equal nil,bug.user
  end

  test "处理bug,关闭bug" do
    clear_model(Bug)
    session[:user_id] = users(:lifei).id
    assert_difference("Bug.count",1) do
      post :create,:bug=>{:kind=>Bug::PROPOSITION,:content=>"BUG内容 blan blan"}
    end
    bug = Bug.last
    assert_equal [bug.handled?,bug.closed?],[false,false]
    get :show,:id=>bug.id
    put :update,:id=>bug,:operate=>"handle"
    bug.reload
    assert_equal bug.handled?,true
    put :update,:id=>bug.id,:operate=>"close"
    bug.reload
    assert_equal bug.closed?,true
  end

end
