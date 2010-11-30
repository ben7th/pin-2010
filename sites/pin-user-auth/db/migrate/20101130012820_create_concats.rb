class CreateConcats < ActiveRecord::Migration
  def self.up
    create_table :concats do |t|
      t.integer :user_id
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :concats
  end
end
