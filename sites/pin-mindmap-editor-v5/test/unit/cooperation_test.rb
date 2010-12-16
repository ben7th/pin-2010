require 'test_helper'

class CooperationTest < ActiveSupport::TestCase

  test "给私有导图 增加 协同查看者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>true)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_cooperate_viewer(lucy)
    end
    assert_equal mindmap.cooperate_viewers.count,1
    assert mindmap.cooperate_viewers.include?(lucy)
    assert mindmap.cooperate_editors.count,0
    assert lucy.cooperate_view_mindmaps.include?(mindmap)

    assert_difference("Cooperation.count",-1) do
      mindmap.remove_cooperate_viewer(lucy.email)
    end
    assert_equal mindmap.cooperate_viewers.count,0
    assert_equal mindmap.cooperate_editors.count,0
  end

  test "给公有导图 增加 协同编辑者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>false)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_cooperate_editor(lucy)
    end
    assert_equal mindmap.cooperate_editors.count,1
    assert mindmap.cooperate_editors.include?(lucy)
    assert_equal mindmap.cooperate_viewers.count,0
    assert lucy.cooperate_edit_mindmaps.include?(mindmap)
    
    assert_difference("Cooperation.count",-1) do
      mindmap.remove_cooperate_editor(lucy)
    end
    assert_equal mindmap.cooperate_editors.count,0
    assert_equal mindmap.cooperate_viewers.count,0
  end

  test "一个用户不能同时是 协同编辑者 协同查看者" do
    assert_difference("Mindmap.count",1) do
      Mindmap.create_by_params(users(:lifei),:title=>"协同测试",:private=>false)
    end
    mindmap = Mindmap.last
    lucy = users(:lucy)
    assert_difference("Cooperation.count",1) do
      mindmap.add_cooperate_editor(lucy.email)
    end
    assert_equal mindmap.cooperate_editors.count,1
    assert mindmap.cooperate_editors.include?(lucy)
    assert mindmap.cooperate_viewers.count,0
    assert_difference("Cooperation.count",0) do
      mindmap.add_cooperate_viewer(lucy)
    end
    assert_equal mindmap.cooperate_editors.count,1
    assert mindmap.cooperate_viewers.count,0
  end
end
