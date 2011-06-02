class RenameTodoMemoCommentsToViewpointComments < ActiveRecord::Migration
  def self.up
    rename_table :todo_memo_comments,:viewpoint_comments
  end

  def self.down
  end
end
