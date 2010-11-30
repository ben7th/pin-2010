class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :operator
      t.integer :target_id
      t.string :target_type
      t.integer :location_id
      t.string :location_type
      t.string :event
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
