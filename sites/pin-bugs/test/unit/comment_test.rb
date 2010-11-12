require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "给 bug 增加 评论" do
    lifei = users(:lifei)
    lucy = users(:lucy)
    admin = users(:admin)
    bug = get_bug(lucy)
    # 创建一个评论
    assert_difference(["Comment.count","bug.comments.count"],1) do
      bug.comments.create(:creator=>lifei,:content=>"ding")
    end
    # 回复一个用户
    assert_difference(["Comment.count","bug.comments.count"],1) do
      bug.comments.create(:creator=>lucy,:content=>"ding",:reply_user=>lifei)
    end
    comment = Comment.last
    assert_equal comment.reply_user,lifei
    # 管理员回复
    assert_difference(["Comment.count","bug.comments.count"],1) do
      bug.comments.create(:creator=>admin,:content=>"管理员我是")
    end
    comment = Comment.last
    assert_equal bug.comments_of_admin,[comment]
  end

  def get_bug(user)
    assert_difference("Bug.count",1) do
      Bug.create!(:content=>"是男人就顶啊",:user_id=>user.id)
    end
    Bug.last
  end
end
