class ModifyOrganizationsAndMembers < ActiveRecord::Migration
  def self.up
    remove_column(:organizations, :user_id)
    add_column :members,:kind,:string
  end

  def self.down
  end
end
