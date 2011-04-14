class CreateTodos < ActiveRecord::Migration
  def self.up
    create_table :todos do |t|
      t.integer :feed_id
      t.integer :creator_id
      t.integer :time
      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
