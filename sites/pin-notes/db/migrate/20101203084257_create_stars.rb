class CreateStars < ActiveRecord::Migration
  def self.up
    create_table :stars do |t|
      t.string :email
      t.integer :note_id
      t.timestamps
    end
  end

  def self.down
    drop_table :stars
  end
end
