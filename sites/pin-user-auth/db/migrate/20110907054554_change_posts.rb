class ChangePosts < ActiveRecord::Migration
  def self.up
    rename_column(:posts,:memo,:detail)
    add_column(:posts,:title,:string)
  end

  def self.down
  end
end
