class AddStatusToTodoUsers < ActiveRecord::Migration
  def self.up
    add_column :todo_users,:status,:string
  end

  def self.down
  end
end
