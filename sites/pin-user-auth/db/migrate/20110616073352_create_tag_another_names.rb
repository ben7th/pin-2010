class CreateTagAnotherNames < ActiveRecord::Migration
  def self.up
    create_table :tag_another_names do |t|
      t.string :name
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_another_names
  end
end
