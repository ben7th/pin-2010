require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test "给 一段摘要创建评论" do
    repo_test do |lifei|
      assert_difference("Note.count",1) do
        note = lifei.notes.create
        assert File.exist?(note.repo.path)
      end

      note = Note.last
      assert_difference(["note.comments.count","Comment.count"],1) do
        note.comments.create(:content=>"摘要评论下",:email=>lifei.email)
      end
      assert_equal lifei,Comment.last.user
    end
  end

end
