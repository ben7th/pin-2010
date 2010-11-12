require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  
  test "创建并且修改tag" do
    clear_model(Tag,Tagging)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    tag_apple = Tag.find_by_value('苹果')
    session[:user_id] = lifei.id
    get :edit,:id=>tag_apple.id
    assert_response :success
    assert_difference("Tag.count",1) do
      put :update,:id=>tag_apple.id,:tag=>{:value=>"茄子"}
    end
    tag_eggplant = Tag.find_by_value('茄子')
    assert_equal tag_eggplant.taggings.count,2
    assert_equal tag_apple.reload.taggings.count,0
  end

  test "合并几个tags" do
    clear_model(Tag,Tagging)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    tag_apple = Tag.find_by_value('苹果')
    tag_orange = Tag.find_by_value('桔子')
    tag_fool = Tag.find_by_value('痴呆')
    session[:user_id] = lifei.id
    get :merge_form,:tag_ids=>[tag_apple.id,tag_orange.id,tag_fool.id]
    assert_response :success
    post :merge,:tag_ids=>[tag_apple.id,tag_orange.id,tag_fool.id],:value=>"合并是也"
    assert_equal tag_apple.taggings.count,0
    tag_merge = Tag.last
    assert_equal tag_merge.value,"合并是也"
    assert_equal tag_merge.taggings.count,2
  end

  test "通过tag找到他的taggable" do
    clear_model(Tag,Tagging)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    session[:user_id] = lifei.id
    get :show,:id=>"苹果"
    assert_response :success
  end
end
