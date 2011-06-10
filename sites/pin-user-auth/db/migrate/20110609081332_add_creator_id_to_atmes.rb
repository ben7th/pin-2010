class AddCreatorIdToAtmes < ActiveRecord::Migration
  def self.up
    add_column :atmes, :creator_id, :integer
  end

  def self.down
  end
end
