class AddCommentReply < ActiveRecord::Migration
  def self.up
    add_column :post_comments, :reply_comment_id, :integer
    add_index  :post_comments, :reply_comment_id
  end

  def self.down
    remove_column :post_comments, :reply_comment_id
  end
end
