class CreateProjectConfigs < ActiveRecord::Migration
  def self.up
    create_table :project_configs do |t|
      t.string  :name
      t.string  :url
      t.text    :database
      t.text    :settings
      t.timestamps
    end
  end

  def self.down
    drop_table :project_configs
  end
end
