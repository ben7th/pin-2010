class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end
    add_index :tags, ["name"], :name => "index_tags_on_name"
  end

  def self.down
    drop_table :tags
  end
end
