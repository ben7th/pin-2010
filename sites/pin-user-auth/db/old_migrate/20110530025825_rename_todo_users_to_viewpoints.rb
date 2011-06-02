class RenameTodoUsersToViewpoints < ActiveRecord::Migration
  def self.up
    rename_table(:todo_users,:viewpoints)
  end

  def self.down
  end
end
