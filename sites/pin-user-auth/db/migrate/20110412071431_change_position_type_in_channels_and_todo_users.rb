class ChangePositionTypeInChannelsAndTodoUsers < ActiveRecord::Migration
  def self.up
    change_column :channels,:position,:decimal,{:precision=>15, :scale=>5}
    change_column :todo_users,:position,:decimal,{:precision=>15, :scale=>5}
  end

  def self.down
  end
end
