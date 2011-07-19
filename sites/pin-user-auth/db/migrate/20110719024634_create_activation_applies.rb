class CreateActivationApplies < ActiveRecord::Migration
  def self.up
    create_table :activation_applies do |t|
      t.string :email
      t.string :name
      t.text :description
      t.string :homepage
      t.timestamps
    end
  end

  def self.down
    drop_table :activation_applies
  end
end
