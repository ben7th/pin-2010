require 'test_helper'

class SharesControllerTest < ActionController::TestCase

  test "分享资源" do
    entry = entries(:entry_1)
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    assert_difference("Share.count",1) do
      post :create,:entry_id=>entry.id,:share=>{:content=>"好东西"}
      post :create,:entry_id=>entry.id
    end
    share = Share.last
    assert_equal share.content,"好东西"
    assert_equal share.creator,lifei
    assert_equal share.entry,entry
    assert_equal lifei.shares.count,1
    assert lifei.shares.include?(share)
  end
end
