require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  test "给entry添加评注" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    entry = entries(:entry_1)
    assert_difference("Comment.count",1) do
      post :create,:entry_id => entry.id,:comment=>{:content=>"第一条评注"}
    end
    assert_equal entry.comments.count,1
    comment = Comment.last
    assert entry.comments.include?(comment)
    assert_equal comment.content,"第一条评注"
  end
end
