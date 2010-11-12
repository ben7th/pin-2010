class CreateWebSiteVisits < ActiveRecord::Migration
  def self.up
    create_table :web_site_visits do |t|
      t.integer :user_id
      t.integer :web_site_id
      t.integer :count
      t.timestamps
    end
  end

  def self.down
    drop_table :web_site_visits
  end
end
