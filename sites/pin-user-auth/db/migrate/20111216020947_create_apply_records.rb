class CreateApplyRecords < ActiveRecord::Migration
  def self.up
    create_table :apply_records do |t|
      t.string :email
      t.string :name
      t.text :description
      t.integer :code_id
      t.boolean :mail_has_send
      t.timestamps
    end
  end

  def self.down
    drop_table :apply_records
  end
end
