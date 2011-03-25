class CreateHtmlDocuments < ActiveRecord::Migration
  def self.up
    create_table :html_documents do |t|
      t.integer :feed_id
      t.text :html
      t.timestamps
    end
  end

  def self.down
    drop_table :html_documents
  end
end
