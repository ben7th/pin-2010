require 'test_helper'

class TagsTest < ActionController::IntegrationTest
  fixtures :all

  test "tags合成，再拆分，再合成" do
    clear_model(Tagging, Tag)
    lifei = users(:lifei)

    entry_1 = entries(:entry_1)
    entry_2 = entries(:entry_2)

    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，甘蔗')

    tag_1 = Tag.find_by_value('苹果')
    tag_2 = Tag.find_by_value('桔子')
    tag_3 = Tag.find_by_value('甘蔗')

    login(users(:lifei))
    
    post '/tags/merge',:tag_ids=>[tag_1.id,tag_2.id,tag_3.id],:value=>"合并是也"
    tag_merged = Tag.last
    assert_equal tag_merged.value,'合并是也'
    assert_equal tag_merged.taggings.count,2

    put "/tags/#{tag_merged.id}" ,:tag=>{:value=>"分开,是也"}
    tag_separate = Tag.find_by_value('分开')
    tag_yes = Tag.find_by_value('是也')
    assert_equal tag_separate.taggings.count,2
    assert_equal tag_yes.taggings.count,2

    post '/tags/merge',:tag_ids=>[tag_separate.id,tag_yes.id],:value=>"再次合并是也"
    tag_merge_again = Tag.last
    assert_equal tag_merge_again.taggings.count,2
    
    logout
  end
  
end
