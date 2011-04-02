class RemoveCreatorEmailFromChannels < ActiveRecord::Migration
  def self.up
    remove_column :channels,:creator_email
  end

  def self.down
  end
end
