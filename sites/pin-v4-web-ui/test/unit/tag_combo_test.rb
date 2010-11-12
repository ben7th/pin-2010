require 'test_helper'

class TagComboTest < ActiveSupport::TestCase

  def load_data
    # 清空相关表格
    clear_model(TagCombo)
    # 读取夹具中的数据
    @lifei = users(:lifei)
    # tag
    @tag_1 = tags(:tag_1)
    @tag_2 = tags(:tag_2)
    @tag_3 = tags(:tag_3)
    @tag_4 = tags(:tag_4)

    # 创建四个tag_combo
    @tag_combo_1 = TagCombo.pack([@tag_1,@tag_4])
    @tag_combo_1.creator = @lifei
    @tag_combo_1.name = "combo-1"
    @tag_combo_1.save
    @tag_combo_2 = TagCombo.pack([@tag_1,@tag_2])
    @tag_combo_2.creator = @lifei
    @tag_combo_2.name = "combo-2"
    @tag_combo_2.save
    @tag_combo_3 = TagCombo.pack([@tag_1,@tag_2,@tag_3])
    @tag_combo_3.creator = @lifei
    @tag_combo_3.name = "combo-3"
    @tag_combo_3.save
    @tag_combo_4 = TagCombo.pack([@tag_1,@tag_2,@tag_3])
    @tag_combo_4.creator = @lifei
    @tag_combo_4.name = "combo-4"
    @tag_combo_4.save
  end
  test "创建一个 tag_combo" do
    # 清空相关表格
    clear_model(TagCombo)
    # 读取夹具中的数据
    lifei = users(:lifei)
    # tag
    tag_1 = tags(:tag_1)
    tag_2 = tags(:tag_2)

    tc = TagCombo.pack([tag_1,tag_2])
    tc.name = "李飞的第一个组合"
    tc.creator = lifei
    tc.save!

    assert_equal TagCombo.count,1
    ntc = TagCombo.last
    assert ntc.tags.include?(tag_1)
    assert ntc.tags.include?(tag_2)
  end

  test "判断子集和超集" do
    load_data
    # 检查 子集 函数
    assert_equal @tag_combo_1.in?(@tag_combo_2),false
    assert_equal @tag_combo_1.in?(@tag_combo_3),false
    assert_equal @tag_combo_1.in?(@tag_combo_4),false

    assert_equal @tag_combo_2.in?(@tag_combo_1),false
    assert_equal @tag_combo_2.in?(@tag_combo_3),true
    assert_equal @tag_combo_2.in?(@tag_combo_4),true

    assert_equal @tag_combo_3.in?(@tag_combo_1),false
    assert_equal @tag_combo_3.in?(@tag_combo_2),false
    assert_equal @tag_combo_3.in?(@tag_combo_4),true

    assert_equal @tag_combo_4.in?(@tag_combo_1),false
    assert_equal @tag_combo_4.in?(@tag_combo_2),false
    assert_equal @tag_combo_4.in?(@tag_combo_3),true
    
    # 检查 超集 函数
    assert_equal @tag_combo_1.include?(@tag_combo_2),false
    assert_equal @tag_combo_1.include?(@tag_combo_3),false
    assert_equal @tag_combo_1.include?(@tag_combo_4),false

    assert_equal @tag_combo_2.include?(@tag_combo_1),false
    assert_equal @tag_combo_2.include?(@tag_combo_3),false
    assert_equal @tag_combo_2.include?(@tag_combo_4),false

    assert_equal @tag_combo_3.include?(@tag_combo_1),false
    assert_equal @tag_combo_3.include?(@tag_combo_2),true
    assert_equal @tag_combo_3.include?(@tag_combo_4),true

    assert_equal @tag_combo_4.include?(@tag_combo_1),false
    assert_equal @tag_combo_4.include?(@tag_combo_2),true
    assert_equal @tag_combo_4.include?(@tag_combo_3),true
  end
  
  test "根据多个 tag_combo 创建一个新的 tag_combo" do
    load_data()
      
    tags_combos = Array.new
    tags_combos << @tag_combo_1
    tags_combos << @tag_combo_2
    tags_combos << @tag_combo_3
    tags_combos << @tag_combo_4

    tc = TagCombo.merge(tags_combos)
    tc.name = "综合的完美的"
    tc.creator = @lifei
    assert_equal tc.tags.size , 4
    assert tc.tags.include? @tag_1
    assert tc.tags.include? @tag_2
    assert tc.tags.include? @tag_3
    assert tc.tags.include? @tag_4
  end

  test " 根据tag_combo来查找对象" do
    # 读取相关数据
    load_data
    
    entry_1 = entries(:entry_1)
    entry_2 = entries(:entry_2)

    assert entry_1.tags.include?(@tag_1)
    assert entry_2.tags.include?(@tag_4)

    targets = @tag_combo_1.targets

    assert targets.include?(entry_1)
    assert targets.include?(entry_2)

    assert_equal targets.size,2
  end

end
