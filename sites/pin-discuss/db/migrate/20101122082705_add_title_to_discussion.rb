class AddTitleToDiscussion < ActiveRecord::Migration
  def self.up
    add_column :discussions, :title, :string
  end

  def self.down
  end
end
