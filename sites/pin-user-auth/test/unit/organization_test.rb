require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  
  test "创建团队" do
    lifei = users(:lifei)
    ori = nil
    assert_difference(["Organization.count","Member.count"],1) do
      ori = Organization.create(:name=>"小李团队",:email=>"xiaoli@gamil.com")
      ori.members.create(:email=>lifei.email,:kind=>Member::KIND_OWNER)
    end
    member = Member.last
    assert_equal member.organization,ori
    assert_equal member.email,lifei.email
    assert ori.owners.include?(lifei)

    assert Organization.owner_of_user(lifei).include?(ori)

    assert_difference(["Organization.count","Member.count"],-1) do
      ori.destroy
    end
  end

end
