require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "给 一段摘要创建评论" do
    note_test do |note|
      lifei = users(:lifei)
      assert_difference(["note.comments.count","Comment.count"],1) do
        note.comments.create(:content=>"摘要评论下",:email=>lifei.email)
      end
      assert_equal lifei,Comment.last.user
    end
  end

end
