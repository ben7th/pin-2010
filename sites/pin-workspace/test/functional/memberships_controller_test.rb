require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  
  test "增加某人到工作空间，该人直接退出" do
    lifei = users(:lifei)
    workspace = workspaces(:workspace_number_one)
    session[:user_id] = lifei.id
    assert_difference(["User.count","Membership.count"],1) do
      post :add_members,:workspace_id=>workspace.id,:emails=>"chinachengliwen@gmail.com"
    end
    user = User.last
    assert_equal user.name,"chinachengliwen@gmail.com"
    assert_equal user.email,"chinachengliwen@gmail.com"
    assert_equal user.activated_at,nil
    
    membership = Membership.last
    assert_equal membership.status,Membership::JOINED 
    assert_equal membership.email,"chinachengliwen@gmail.com"
    uuid_code = membership.uuid_code

    # 该人退出
    get :quit,:code=>uuid_code,:workspace_id=>workspace.id
    membership.reload
    assert_equal membership.status,Membership::QUIT
  end

  test "邀请某人到工作空间，该人加入后退出" do
    lifei = users(:lifei)
    workspace = workspaces(:workspace_number_one)
    session[:user_id] = lifei.id
    assert_difference("Membership.count",1) do
      post :invite_members,:workspace_id=>workspace.id,:emails=>"chinachengliwen@gmail.com"
    end
    membership = Membership.last
    assert_equal membership.status,Membership::INVITE
    code = membership.uuid_code

    # 该人加入
    assert_difference("User.count",1) do
      get :join,:code=>code,:workspace_id=>workspace.id
    end
    user = User.last
    assert_equal user.name,"chinachengliwen@gmail.com"
    assert_equal user.email,"chinachengliwen@gmail.com"
    assert_equal user.activated_at,nil

    assert_equal membership.reload.status,Membership::JOINED
    
    # 该人退出
    get :quit,:code=>code,:workspace_id=>workspace.id
    assert_equal membership.reload.status,Membership::QUIT
  end

  test "用户主动申请加入工作空间" do
    lucy = users(:lucy)
    session[:user_id] = lucy.id
    workspace = workspaces(:workspace_number_one)
    assert_difference("Membership.count",1) do
      post :apply_join,:workspace_id=>workspace.id
    end
    membership = Membership.last
    assert_equal membership.status,Membership::APPLY
  end

  test "同意某人的申请" do
    lucy = users(:lucy)
    workspace = workspaces(:workspace_number_one)
    lucy.apply_join(workspace)
    membership = Membership.last
    assert_difference("Membership.count",0) do
      put :approve,:workspace_id=>workspace.id,:id=>membership.id
    end
    assert_equal membership.reload.status,Membership::JOINED
  end

  test "拒绝某人的申请" do
    lucy = users(:lucy)
    workspace = workspaces(:workspace_number_one)
    lucy.apply_join(workspace)
    membership = Membership.last
    assert_difference("Membership.count",0) do
      put :refuse,:workspace_id=>workspace.id,:id=>membership.id
    end
    assert_equal membership.reload.status,Membership::REFUSED
  end

  test "把某人从工作空间中剔除" do
    lucy = users(:lucy)
    session[:user_id] = users(:lifei)
    workspace = workspaces(:workspace_number_one)
    workspace.add_member(lucy)
    membership = Membership.last
    assert_difference("Membership.count",0) do
      put :kick_out,:workspace_id=>workspace.id,:id=>membership.id
    end
    assert_equal membership.reload.status,Membership::QUIT
  end

  test "把某人从工作空间联系人列表中，踢到黑名单,然后在解救出来（闲的蛋疼是也）" do
    lucy = users(:lucy)
    session[:user_id] = users(:lifei)
    workspace = workspaces(:workspace_number_one)
    workspace.add_member(lucy)
    membership = Membership.last
    assert_difference("Membership.count",0) do
      put :ban,:workspace_id=>workspace.id,:id=>membership.id
    end
    assert_equal membership.reload.status,Membership::BANED

    # 加入黑名单之后，再声请加入是无效的
    code = membership.uuid_code
    get :join,:code=>code,:workspace_id=>workspace.id
    assert_equal membership.reload.status,Membership::BANED
    # 申请也是无效的
    lucy.apply_join(workspace)
    assert_equal membership.reload.status,Membership::BANED
    
    assert_difference("Membership.count",0) do
      put :unban,:workspace_id=>workspace.id,:id=>membership.id
    end
    assert_equal membership.reload.status,Membership::JOINED
  end

end
