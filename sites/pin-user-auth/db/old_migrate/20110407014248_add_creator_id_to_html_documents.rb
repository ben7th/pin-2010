class AddCreatorIdToHtmlDocuments < ActiveRecord::Migration
  def self.up
    add_column :html_documents,:creator_id,:integer
  end

  def self.down
  end
end
