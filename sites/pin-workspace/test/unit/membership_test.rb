require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  
  test "工作空间管理者给工作空间增加 邮件成员" do
    lifei = users(:lifei)
    ws = create_workspace(lifei)
    assert_equal ws.member_emails.count,0

    # 增加一个成员
    assert_difference(["User.count","Membership.count"],1) do
      ws.add_member("zhanwairenyuan@mindpin.com")
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::JOINED
    assert_equal ws.member_emails.count,1
    # 新增加的用户
    user = User.last
    assert_equal user.name,"zhanwairenyuan@mindpin.com"
    assert_equal user.email,"zhanwairenyuan@mindpin.com"
    assert_equal user.activated_at,nil

    # 增加多个成员
    assert_difference("Membership.count",3) do
      ws.add_members(['nyuan@mindpin.com','xaoniao@163.com','zhutou@163.com'])
    end
    ws.reload
    assert_equal ws.member_emails.count,4
  end

  test "工作空间管理者给工作空间增加成员" do
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    ws = create_workspace(lifei)
    assert_equal ws.member_emails.count,0

    assert_difference("User.count",0) do
      assert_difference("Membership.count",1) do
        ws.add_member(chengliwen.email)
      end
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::JOINED
    assert_equal ws.member_emails.count,1
  end

  test "围观群众申请加入工作空间，被允许" do
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    ws = create_workspace(lifei)
    assert_equal ws.member_emails.count,0
    assert_difference("Membership.count",1) do
      chengliwen.apply_join(ws)
    end
    ms = Membership.last
    assert_equal ms.status,Membership::APPLY
    assert_equal ws.member_emails.count,0
    assert_equal ws.apply_member_emails.count,1

    assert_difference("User.count",0) do
      assert_difference("Membership.count",0) do
        ws.add_member(chengliwen)
      end
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::JOINED
    assert_equal ws.member_emails.count,1
    assert_equal ws.apply_member_emails.count,0
  end
  
  test "围观群众申请加入工作空间，被拒绝，在申请后，被允许" do
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    ws = create_workspace(lifei)
    assert_equal ws.member_emails.count,0
    assert_difference("Membership.count",1) do
      chengliwen.apply_join(ws)
    end
    ms = Membership.last
    assert_equal ms.status,Membership::APPLY
    assert_equal ws.apply_member_emails.count,1
    assert_equal ws.member_emails.count,0

    assert_difference("Membership.count",0) do
      ws.refuse_join(chengliwen)
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::REFUSED
    assert_equal ws.apply_member_emails.count,0
    assert_equal ws.member_emails.count,0

    assert_difference("Membership.count",0) do
      chengliwen.apply_join(ws)
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::APPLY
    assert_equal ws.apply_member_emails.count,1
    assert_equal ws.member_emails.count,0

    assert_difference("Membership.count",0) do
      ws.add_member(chengliwen)
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::JOINED
    assert_equal ws.apply_member_emails.count,0
    assert_equal ws.member_emails.count,1
  end

  test "围观群众申请加入工作空间，没有反应，在申请，被允许" do
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    ws = create_workspace(lifei)
    assert_equal ws.member_emails.count,0
    assert_difference("Membership.count",1) do
      chengliwen.apply_join(ws)
    end
    ms = Membership.last
    assert_equal ms.status,Membership::APPLY
    assert_equal ws.apply_member_emails.count,1
    assert_equal ws.member_emails.count,0
    # 等了很久
    assert_difference("Membership.count",0) do
      chengliwen.apply_join(ws)
    end
    ms = Membership.last
    assert_equal ms.status,Membership::APPLY
    assert_equal ws.apply_member_emails.count,1
    assert_equal ws.member_emails.count,0
    # 加入
    assert_difference("Membership.count",0) do
      ws.add_member(chengliwen)
    end
    ws.reload
    ms = Membership.last
    assert_equal ms.status,Membership::JOINED
    assert_equal ws.apply_member_emails.count,0
    assert_equal ws.member_emails.count,1
  end

  def create_workspace(user)
    assert_difference("Workspace.count",1) do
      Workspace.create(:name=>"成员管理测试专用空间",:user=>user)
    end
    return Workspace.last
  end

end
