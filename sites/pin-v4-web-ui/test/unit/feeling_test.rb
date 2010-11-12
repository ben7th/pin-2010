require 'test_helper'

class FeelingTest < ActiveSupport::TestCase
  test "对一个资源进行评价（好或坏）" do
    lifei = users(:lifei)
    entry = Entry.create!(:user=>lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本1",:content => "文本1内容"}})
    # 还没有评价
    assert_equal nil,entry.feel_of(lifei)
    assert_equal 0,entry.feelings.evaluation_equals(Feeling::GOOD).count
    assert_equal 0,entry.feelings.evaluation_equals(Feeling::BAD).count

    # 李飞评价好
    assert_difference("Feeling.count",1) do
      entry.feel_good_or_cancel_feel(lifei)
    end
    assert_equal Feeling::GOOD,entry.feel_of(lifei)
    assert_equal 1,entry.feelings.evaluation_equals(Feeling::GOOD).count
    assert_equal 0,entry.feelings.evaluation_equals(Feeling::BAD).count

    # 李飞评价坏
    assert_difference("Feeling.count",0) do
      entry.feel_bad(lifei)
    end
    assert_equal Feeling::BAD,entry.feel_of(lifei)
    assert_equal 0,entry.feelings.evaluation_equals(Feeling::GOOD).count
    assert_equal 1,entry.feelings.evaluation_equals(Feeling::BAD).count
  end
end