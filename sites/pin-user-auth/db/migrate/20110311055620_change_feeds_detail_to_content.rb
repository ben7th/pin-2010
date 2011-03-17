class ChangeFeedsDetailToContent < ActiveRecord::Migration
  def self.up
    rename_column(:feeds,:detail,:content)
  end

  def self.down
  end
end
