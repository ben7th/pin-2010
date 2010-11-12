require 'test_helper'

class BugCommentsControllerTest < ActionController::TestCase

  test "登录提交一个bug" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    bug = get_bug(lifei)
    assert_difference("bug.comments.count",1) do
      post :create,:bug_id=>bug.id,:comment=>{:content=>"这个bug 确实存在"}
    end
  end

  def get_bug(user)
    content = "BUG内容 blan blan"
    assert_difference("Bug.count",1) do
      Bug.create!(:content=>content,:user=>user)
    end
    Bug.last
  end

end
