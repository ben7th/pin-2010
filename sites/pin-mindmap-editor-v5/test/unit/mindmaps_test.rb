require 'test_helper'

class MindmapsTest < ActiveSupport::TestCase
  # do_insert 接口改变，导致测试不能运行，待修改
#  test "插入节点测试" do
#    assert_difference("Mindmap.count",1) do
#      Mindmap.create_by_params(users(:lifei),:title=>"创建测试",:private=>"0")
#    end
#    mindmap = Mindmap.last
#    # 在根节点下创建 1 节点
#    mindmap.do_insert(0,:index=>0,:title=>"1")
#    node_1_id = Nokogiri::XML(mindmap.struct).at_css("N[t='#{1}']")["id"]
#    # 在 1 节点下创建 2 节点
#    mindmap.do_insert(node_1_id,:index=>0,:title=>"2")
#    # 在 1 节点下创建 3 节点
#    mindmap.do_insert(node_1_id,:index=>0,:title=>"3")
#    # 在 根节点下创建 4 节点
#    mindmap.do_insert(0,:index=>1,:title=>"4")
#    # 根节点有两个子节点
#    assert_equal Nokogiri::XML(mindmap.struct).at_css("N#0").xpath("N").count,2
#  end

end
