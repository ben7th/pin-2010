require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "增加成员，删除成员" do
    org = organizations("org_xiaoli")
    lifei = users("lifei")
    lucy = users("lucy")
    assert_difference(["Member.count","Activity.count"],1) do
      member = Member.create(:organization_id=>org.id,:email=>"lucy@gmail.com",:kind=>Member::KIND_COMMON)
      Activity.create(:operator=>lifei.email,:location=>org,:target_type=>"User", :target_id=>lucy.id,:event=>Activity::ADD_ORG_MEMBER)
    end
    activity = Activity.last
    assert_equal activity.operator,lifei.email
    assert_equal activity.location,org
    assert_equal activity.target,lucy
    assert_equal activity.event,Activity::ADD_ORG_MEMBER
  end
end
