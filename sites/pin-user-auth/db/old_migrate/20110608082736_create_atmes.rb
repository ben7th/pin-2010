class CreateAtmes < ActiveRecord::Migration
  def self.up
    create_table :atmes do |t|
      t.integer :user_id
      t.integer :atable_id
      t.string :atable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :atmes
  end
end
