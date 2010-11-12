require 'test_helper'

class ReadingTest < ActiveSupport::TestCase

  test "对几个资源进行阅读" do
    # 清空
    Reading.all.each {|reading| reading.destroy}
    # 用户
    lifei = users(:lifei)
    dave = users(:dave)
    # 资源
    entry_1 = entries(:entry_1)
    entry_2 = entries(:entry_2)
    entry_3 = entries(:entry_3)
    # 李飞 阅读一个资源
    lifei.reading_resources(entry_1)
    # 断言
    assert_equal 1, Reading.count
#    assert_equal 1, lifei.read_resources.count
    assert_equal 1, entry_1.reading_users.count
    # 李飞 阅读多个资源
    lifei.reading_resources([entry_2,entry_3])
    # 断言
    assert_equal 3, Reading.count
#    assert_equal 3, lifei.read_resources.count
    assert_equal 1, entry_2.reading_users.count
    assert_equal 1, entry_3.reading_users.count
    # dave 阅读多个资源
    dave.reading_resources([entry_1,entry_2,entry_3])
    # 断言
    assert_equal 6,Reading.count
#    assert_equal 3,dave.read_resources.count
    assert_equal 2,entry_1.reading_users.count
    assert_equal 2,entry_2.reading_users.count
    assert_equal 2,entry_3.reading_users.count
    # 李飞 再次阅读多个资源
    lifei.reading_resources([entry_1,entry_2])
    lifei.reading_resources(entry_1)
    # 断言
    assert_equal 6,Reading.count
#    assert_equal 3,lifei.read_resources.count
  end
end
