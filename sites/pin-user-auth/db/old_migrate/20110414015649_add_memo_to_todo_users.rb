class AddMemoToTodoUsers < ActiveRecord::Migration
  def self.up
    add_column :todo_users, :memo, :text
  end

  def self.down
    remove_column :todo_users, :memo
  end
end
