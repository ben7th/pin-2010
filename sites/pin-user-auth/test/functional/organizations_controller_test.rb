require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  
  test "增加某人到工作空间，该人直接退出" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    assert_difference(["Organization.count","Member.count"],1) do
      post :create,:organization=>{:name=>"大家的团队",:email=>"qdclw1986@sina.cn"}
    end
    ori = Organization.last
    assert_equal ori.name,"大家的团队"
    assert_equal ori.email,"qdclw1986@sina.cn"
    member = Member.last
    assert_equal member.organization,ori
    assert_equal member.email,lifei.email
    assert_equal member.kind,Member::KIND_OWNER
    assert ori.owners.include?(lifei)
  end

end
