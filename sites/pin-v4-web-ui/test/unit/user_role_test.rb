require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase
  
  test "管理员修改某人的角色" do

    admin,dave,lifei = users(:admin),users(:dave),users(:lifei)
    role_student,role_teacher = roles(:role_student),roles(:role_teacher)
    assert_equal lifei.role, role_student.name
    # 管理员修改用户的角色
    with_user admin do
      admin.modify_role_of_user(lifei,role_teacher)
    end
    lifei.reload
    assert_equal lifei.role,role_teacher.name
    # 非管理员用户不能修改其他用户的角色
    assert_raise Authorization::NotAuthorized do
      with_user dave do
        dave.modify_role_of_user(lifei,role_student)
      end
    end
    lifei.reload
    assert_equal lifei.role,role_teacher.name
  end
end
