class DeleteActivationApplies < ActiveRecord::Migration
  def self.up
    drop_table :activation_applies
  end

  def self.down
  end
end
