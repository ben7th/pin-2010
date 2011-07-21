class CreateActivationCodes < ActiveRecord::Migration
  def self.up
    create_table :activation_codes do |t|
      t.string :code
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :activation_codes
  end
end
