require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  test "给 note 创建评论,编辑评论,删除评论" do
    note_test do |note|
      lifei = users(:lifei)
      session[:user_id] = lifei.id
      content = "我写的这个 note 太漂亮了"
      assert_difference("note.comments.count",1) do
        post :create,:note_id=>note.id,:comment=>{:content=>content}
      end
      comment = note.comments.last
      assert_equal comment.user,lifei
      assert_equal comment.content,content

      # 编辑
      content_edit = "也不是很完美"
      put :update,:id=>comment.id,:comment=>{:content=>content_edit}
      comment.reload
      assert_equal comment.content,content_edit
      # 删除
      assert_difference("note.comments.count",-1) do
        delete :destroy,:id=>comment.id
      end
    end
  end

end
