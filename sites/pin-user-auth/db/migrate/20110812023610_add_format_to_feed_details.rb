class AddFormatToFeedDetails < ActiveRecord::Migration
  def self.up
    add_column(:feed_details, :format, :string, :null => false, :default => "markdown")
  end

  def self.down
  end
end
