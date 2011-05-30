class RenameTodoUserIdToViewpointIdInViewpointComments < ActiveRecord::Migration
  def self.up
    rename_column :viewpoint_comments,:todo_user_id,:viewpoint_id
  end

  def self.down
  end
end
