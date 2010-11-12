require 'test_helper'

class ContactingsControllerTest < ActionController::TestCase
  
  test "添加朋友,删除朋友" do
    clear_model(Contacting)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    songliang = users(:songliang)
    session[:user_id] = lifei.id
    assert_difference("Contacting.count",2) do
      post :create,:contact_id=>chengliwen.id
      post :create,:contact_id=>songliang.id
    end
    lifei.reload
    assert lifei.contacts.include?(chengliwen)
    assert lifei.contacts.include?(songliang)

    contacting = Contacting.find(:first,:conditions=>{:host_id=>lifei.id,:contact_id=>songliang.id})
    assert_difference("Contacting.count",-1) do
      delete :destroy,:id=>contacting.id
    end
    lifei.reload
    assert lifei.contacts.include?(chengliwen)
    assert !lifei.contacts.include?(songliang)
  end
end
