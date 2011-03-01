class CoreService

  USER_AUTH = "pin-user-auth"
  NOTES = "pin-notes"
  MEV6 = "pin-mev6"

  def self.find_setting_by_project_name(project_name)
    setting = GlobalConfig::SETTING_CONFIG[project_name]
    raise "没有 #{project_name} 这个工程的 配置文件" if setting.nil?
    setting[RAILS_ENV]
  end

  def self.find_database_by_project_name(project_name)
    project_path = GlobalConfig::PROJECT_PATH_CONFIG[project_name]
    raise "没有 #{project_name} 这个工程 配置文件" if project_path.nil?
    YAML.load_file(File.join(project_path,"config/database.yml"))[RAILS_ENV]
  end

end
