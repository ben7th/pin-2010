require 'test_helper'

class MembersControllerTest < ActionController::TestCase

  test "增加成员，删除成员" do
    org = organizations("org_xiaoli")
    lifei = users("lifei")
    lucy = users("lucy")
    session[:user_id] = lifei.id
    assert_difference(["Member.count","Activity.count"],1) do
      post :create,:organization_id=>org.id,:member=>{:email=>lucy.email}
    end
    activity = Activity.last
    assert_equal activity.operator,lifei.email
    assert_equal activity.location,org
    assert_equal activity.target,lucy
    assert_equal activity.event,Activity::ADD_ORG_MEMBER
    assert_difference(["Activity.count"],1) do
      assert_difference(["Member.count"],-1) do
        delete :destroy,:organization_id=>org.id,:id=>Member.last.id
      end
    end
    activity = Activity.last
    assert_equal activity.operator,lifei.email
    assert_equal activity.location,org
    assert_equal activity.target,lucy
    assert_equal activity.event,Activity::DELETE_ORG_MEMBER

  end

end
