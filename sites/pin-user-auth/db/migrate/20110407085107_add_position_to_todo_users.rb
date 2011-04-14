class AddPositionToTodoUsers < ActiveRecord::Migration
  def self.up
    add_column :todo_users,:position,:integer
  end

  def self.down
  end
end
