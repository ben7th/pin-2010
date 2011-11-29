class AddImageMetaToImageAttachments < ActiveRecord::Migration
  def self.up
    add_column :image_attachments,:image_meta,:text
  end

  def self.down
  end
end
