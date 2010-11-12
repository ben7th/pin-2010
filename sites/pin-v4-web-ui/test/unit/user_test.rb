require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "创建一个用户" do
    assert_difference(["Preference.count","User.count"],1) do
      user=User.new(:email=>"fushang333@gmail.com",:name=>"fushang333",:password=>"fushang31",:password_confirmation=>"fushang31")
      # 生成验证码、验证码过期时间、初始激活状态
      user.create_activation_code
      user.save
    end
  end
end