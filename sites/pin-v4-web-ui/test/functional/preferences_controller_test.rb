require 'test_helper'

class PreferencesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test '个人偏好设置修改' do
    # 用户登录
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    # 在访问偏好设置之前，没有创建他的偏好。在该用户访问他的偏好时，如果该用户没有偏好，则创建之
    assert_equal lifei.preference.blank?,true
    get :edit
    lifei.reload
    assert_equal lifei.preference.blank?,false
    assert_equal lifei.preference.auto_popup_msg,true
    put :update,:preference=>{:auto_popup_msg=>false}
    lifei.reload
    assert_equal lifei.preference.auto_popup_msg,false
  end
  
end
