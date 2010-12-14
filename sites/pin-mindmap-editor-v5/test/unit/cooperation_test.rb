require 'test_helper'

class CooperationTest < ActiveSupport::TestCase

  test "给私有导图 增加 协同查看者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>true)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_read_cooperators([lucy])
    end
    assert_equal mindmap.read_cooperators.count,1
    assert mindmap.read_cooperators.include?(lucy)
    assert mindmap.write_cooperators.count,0
  end

  test "给公有导图 增加 协同编辑者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>false)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_write_cooperators([lucy])
    end
    assert_equal mindmap.write_cooperators.count,1
    assert mindmap.write_cooperators.include?(lucy)
    assert mindmap.read_cooperators.count,0
  end

  test "一个用户不能同时是 协同编辑者 协同查看者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>false)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_write_cooperators([lucy])
    end
    assert_equal mindmap.write_cooperators.count,1
    assert mindmap.write_cooperators.include?(lucy)
    assert mindmap.read_cooperators.count,0
    assert_difference("Cooperation.count",0) do
      mindmap.add_read_cooperators([lucy])
    end
    assert_equal mindmap.write_cooperators.count,1
    assert mindmap.read_cooperators.count,0
  end
end
