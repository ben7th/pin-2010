class AddSendStatusToMindmaps < ActiveRecord::Migration
  def self.up
    add_column(:mindmaps, :send_status, :string)
  end

  def self.down
  end
end
