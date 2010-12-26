class CreateCooperations < ActiveRecord::Migration
  def self.up
    create_table :cooperations do |t|
      t.integer :mindmap_id
      t.string :email
      t.string :kind
      t.timestamps
    end
  end

  def self.down
    drop_table :cooperations
  end
end
