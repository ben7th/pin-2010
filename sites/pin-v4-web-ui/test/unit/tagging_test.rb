require 'test_helper'

class TaggingTest < ActiveSupport::TestCase

  def run_text_by_target(target)
    # 创建几个 tag
    songliang = users(:songliang)

    # 给 资源 增加 用户TAG
    assert_difference(['Tag.count','Tagging.count'],2) do
      target.set_user_tags!(songliang,"苹果，梨子")
    end
    target.reload
    assert_equal target.tags.of_user(songliang).count,2
    values = target.tags.of_user(songliang).map{|tag|tag.value}
    assert_equal [],values - ["苹果","梨子"]
    # 给 资源修改 用户TAG
    assert_difference(['Tag.count'],2) do
      assert_difference(['Tagging.count'],0) do
        target.set_user_tags!(songliang,"香蕉,桔子")
      end
    end
    target.reload
    assert_equal target.tags.of_user(songliang).count,2
    values = target.tags.of_user(songliang).map{|tag|tag.value}
    assert_equal [],values - ["香蕉","桔子"]
  end
  
  test "给  Entry 建立几个 tag" do
    # 文本资源
    entry = text_entries(:text_1).entry
    run_text_by_target(entry)
  end

  test "某人查找同时拥有两个tag的taggable" do
    clear_model(Tagging, Tag)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_3 = text_entries(:text_3).entry
    entry_4 = text_entries(:text_4).entry
    entry_1.set_user_tags!(lifei,'苹果，想家,桔子')
    entry_2.set_user_tags!(lifei,'苹果，想家,痴呆')
    entry_3.set_user_tags!(lifei,'苹果，想家')
    entry_4.set_user_tags!(lifei,'苹果')
    tag1 = Tag.find_by_value_and_user_id('苹果',lifei.id)
    tag2 = Tag.find_by_value_and_user_id('想家',lifei.id)
    taggables = Tagging.find_by_tags([tag1,tag2])
    assert_equal taggables.count,3
    assert taggables.include?(entry_1)
    assert taggables.include?(entry_2)
    assert taggables.include?(entry_3)
  end

end
