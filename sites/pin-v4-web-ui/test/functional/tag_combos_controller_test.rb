require 'test_helper'

class TagCombosControllerTest < ActionController::TestCase
  
  test "给多个tags创建一个tag_combo" do
    clear_model(Tagging, Tag,TagCombo,ComboLink)
    lifei = users(:lifei)
    entry_1 = text_entries(:text_1).entry
    entry_2 = text_entries(:text_2).entry
    entry_1.set_user_tags!(lifei,'苹果，桔子')
    entry_2.set_user_tags!(lifei,'苹果，痴呆')
    tag_apple = Tag.find_by_value('苹果')
    tag_orange = Tag.find_by_value('桔子')
    tag_fool = Tag.find_by_value('痴呆')
    session[:user_id] = lifei.id
    assert_difference(["Tag.count"],1) do
      get :new,:tag_values=>['苹果','桔子','痴呆',"傻瓜"]
    end
    tag_shagua = Tag.find_by_value('傻瓜')
    assert_response :success
    assert_difference(["TagCombo.count"],1) do
      post :create,:tag_ids=>[tag_apple.id,tag_orange.id,tag_fool.id,tag_shagua.id],:tag_combo=>{:name=>"合并标签"}
    end
    tag_combo = TagCombo.last
    assert_equal ComboLink.count,4
    assert_equal tag_combo.name,"合并标签"
    assert_equal tag_combo.tags.count,4
    assert tag_combo.tags.include?(tag_apple)
    assert tag_combo.tags.include?(tag_orange)
    assert tag_combo.tags.include?(tag_fool)
    assert tag_combo.tags.include?(tag_shagua)
  end
end
