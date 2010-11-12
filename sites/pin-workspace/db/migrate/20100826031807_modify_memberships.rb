class ModifyMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :uuid_code, :string
  end

  def self.down
  end
end
