require 'test_helper'

class SystemSettingTest < ActiveSupport::TestCase
 
  test "系统信息的设置" do
    # 在system_setting的数据表中，应该只存在一条记录，以后的操作都是建立在对他的修改之上的
    SystemSetting.all.each{|system_setting| system_setting.destroy }
    SystemSetting.create!(
      :name => "我们的系统",
      :footer_info => "系统的页脚信息",
      :logo_file_name => "logo",
      :logo_content_type => "jpg",
      :logo_file_size => 12345,
      :logo_updated_at => Time.now,
      :login_info => "欢迎你，管理员"
    )
    assert_equal SystemSetting.count,1
  end
end
