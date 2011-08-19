class AddColumnsToPosts < ActiveRecord::Migration
  def self.up
    add_column(:posts, :kind, :string,:null => false, :default => "normal")
    add_column(:posts, :format, :string,:null => false, :default => "markdown")
  end

  def self.down
  end
end
