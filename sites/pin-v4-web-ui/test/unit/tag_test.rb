require 'test_helper'

class TagTest < ActiveSupport::TestCase


  test "根据一个关键字，查找目标对象" do
    lifei = users(:lifei)
    # 目标对象
    entry_1 = entries(:entry_1)
    entry_2 = entries(:entry_2)

    assert_difference('Tag.count',1) do
      entry_1.add_tag(lifei,"红豆")
      entry_2.add_tag(lifei,"红豆")
    end
    tag = Tag.last
    targets = tag.targets
    # 断言
    assert_equal targets.size , 2
    assert targets.include?(entry_1)
    assert targets.include?(entry_2)
  end

  def prepare_for_tag_value_update_tests
    clear_model(Tagging, Tag)

    text_1 = text_entries(:text_1)
    lifei = users(:lifei)

    entry = text_1.entry
    # 李飞给资源标注了 “北京，深秋，严寒” 的tag
    entry.set_user_tags!(lifei, '北京，深秋，严寒')
  end

  def assert_arr_equal(arr1,arr2)
    assert_equal((arr1 & arr2),(arr1 | arr2))
    assert_equal(arr1.size,arr2.size)
  end

  def test_tags_value_update(options)
    tag_value = options[:tag_value]
    new_tag_value = options[:new_tag_value]
    tags_of_lifei_should_be = options[:tags_of_lifei_should_be]

    prepare_for_tag_value_update_tests

    entry = text_entries(:text_1).entry.reload
    lifei = users(:lifei).reload

    tag = Tag.find_by_value_and_user_id(tag_value,lifei.id)
    tag.value_str = new_tag_value
    tags_str_arr = entry.tags.of_user(lifei).map do|each_tag|
      each_tag.value
    end
    assert_arr_equal tags_str_arr,tags_of_lifei_should_be
  end

  # tag的值修改分为很多情况，以一个用户的tag作为测试基准：
  # +--------------------+    +--------------+  改为 +-------------------+
  # |                    | -> |  1 -> 1（甲） |  ->  |  自己以前有的 （A） |
  # |                    |    +--------------+      |                   |
  # |                    |    +--------------+      |  自己以前没有的 (B) |
  # +--------------------+    |  1 -> n（乙） |      |                   |
  #                           +--------------+      +-------------------+
  #                                            
  # 总共 1*2*2 = 4 个用例

  test "tag的值修改" do
    tase_case_array = []

    # lifei               北京，深秋，严寒

    # 甲 A 型
    tase_case_array << ['深秋','严寒',['严寒','北京']]

    # 甲 B 型
    tase_case_array << ['深秋','胡萝卜',['严寒','北京','胡萝卜']]

    tase_case_array.each do |arr|
      test_tags_value_update({
          :tag_value => arr[0],
          :new_tag_value => arr[1],
          :tags_of_lifei_should_be => arr[2],
        })
    end
  end

  test '某用户对于某资源的tag' do
    clear_model(Tagging, Tag)

    text_1 = text_entries(:text_1)
    songliang = users(:songliang)
    lifei = users(:lifei)
    entry = text_1.entry
    entry.set_user_tags!(songliang,'苹果，桔子')
    entry.set_user_tags!(lifei,'萝卜，西红柿，土豆')

    assert '苹果,桔子',entry.tags_str_of(songliang)
    assert 2,entry.tags.of_user(songliang).size

    assert '萝卜,西红柿,土豆',entry.tags_str_of(lifei)
    assert 3,entry.tags.of_user(lifei).size

    assert '苹果,桔子,萝卜,西红柿,土豆',entry.tags_str
    assert 5,entry.tags
  end

  test "得到某人在某类里面添加的所有tags" do
    clear_model(Tagging, Tag)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_3 = file_entries(:file_1).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'傻瓜，痴呆')
    entry_3.set_user_tags!(lifei,'文件，档案')
    assert_equal 4,Entry.tags_of(lifei,:conditions=>['entries.resource_type = ?','TextEntry']).count
    assert_equal 2,Entry.tags_of(lifei,:conditions=>['entries.resource_type = ?','FileEntry']).count
  end

  test "一个tag被一个人使用的次数,以及相关联的tags" do
    clear_model(Tagging, Tag)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    tag_apple = Tag.find_by_value_and_user_id('苹果',lifei.id)
    tag_orange = Tag.find_by_value_and_user_id('桔子',lifei.id)
    tag_fool = Tag.find_by_value('痴呆')
    assert_equal tag_apple.used_times_by_user(lifei),2
    assert tag_apple.related_tags.include?(tag_orange)
    assert tag_apple.related_tags.include?(tag_fool)
  end

  test "某人，修改了自己的tag，与之关联的tagging也相应的迁移" do
    clear_model(Tagging, Tag)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    tag_apple = Tag.find_by_value_and_user_id('苹果',lifei.id)
    assert_difference(["Tag.count"],1) do 
      tag_apple.change_value_to("菠萝")
    end
    tag_pineapple = Tag.find_by_value_and_user_id('菠萝',lifei.id)
    assert_equal tag_pineapple.taggings.count,2
  end

end
