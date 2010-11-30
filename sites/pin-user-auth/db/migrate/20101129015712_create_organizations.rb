class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
