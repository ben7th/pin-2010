require 'test_helper'

class ResetPasswordTest < ActionController::IntegrationTest
  fixtures :all
  test "新用户（非v09用户）重设密码测试" do
    new_password = "xmm1234"
    lifei = users(:lifei)
    assert_not_equal lifei,User.authenticate(lifei.email,new_password)
    _flow_test(lifei,new_password)
    lifei.reload
    assert_equal lifei,User.authenticate(lifei.email,new_password)
  end

  test "v09用户 重设密码测试" do
    new_password = "xmm4567"
    v09_lifei = users(:v09_lifei)
    assert_not_equal v09_lifei,User.v09_authenticate(v09_lifei.name,new_password)
    _flow_test(v09_lifei,new_password)
    v09_lifei.reload
    assert_equal v09_lifei,User.v09_authenticate(v09_lifei.name,new_password)
  end

  def _flow_test(user,new_password)
    # 进入忘记密码页面
    get "/forgot_password_form"
    assert_response :success
    # 填写电子邮箱，获得链接
    post "/forgot_password",:email=>user.email
    assert_equal assigns("user"),user
    reset_password_code = assigns("user").reset_password_code
    assert_redirected_to "/forgot_password_form"
    user.reload
    # 进入重设密码表单页面
    get "/reset_password/#{reset_password_code}"
    assert_equal assigns("user"),user
    # 重设密码
    post "/change_password/#{reset_password_code}",:user=>{:password=>new_password,:password_confirmation=>new_password}
  end
end