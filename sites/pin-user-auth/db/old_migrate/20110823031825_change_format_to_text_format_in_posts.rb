class ChangeFormatToTextFormatInPosts < ActiveRecord::Migration
  def self.up
    rename_column(:posts,:format,:text_format)
  end

  def self.down
  end
end
