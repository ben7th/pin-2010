require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  
  test "创建团队，以及最后的管理员不能退出" do
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
    
    assert_equal ori.leave(lifei),false
    assert_difference(["Organization.count","Member.count"],0) do
      delete :leave,:id=>ori.id
    end
    
  end

end
