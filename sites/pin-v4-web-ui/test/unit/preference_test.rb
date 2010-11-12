require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "偏好设置模型测试" do
    # 清空表格
    Preference.all.each { |e| e.destroy }
    lifei = users(:lifei)
    pre_new = Preference.new(:user_id=>lifei.id)
    pre_new.save!
    pre = Preference.last
    assert_equal pre.user,lifei
    assert_equal lifei.preference,pre
    assert_equal pre.auto_popup_msg,true
  end
end
