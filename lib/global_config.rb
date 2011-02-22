require "yaml"
class GlobalConfig
  yml_file_dir = File.join(File.dirname(File.expand_path(__FILE__)),"config_yml")
  pin_2010_path = File.join(File.dirname(File.expand_path(__FILE__)),"..")
  yml_file_names = Dir.entries(yml_file_dir).select{|file_name|!!file_name.match(/\.yml/)}

  # 初始化 SETTING_CONFIG
  setting_config = {}
  yml_file_names.each do |fname|
    project_name = fname.gsub(".yml","")
    setting_config[project_name] = YAML.load_file(File.join(yml_file_dir,fname))
  end
  SETTING_CONFIG = setting_config

  # 初始化 PROJECT_PATH_CONFIG
  project_path_config = {}
  # sites
  site_project_paths = Dir.entries(File.join(pin_2010_path,"sites")).select{|fname|!!fname.match(/^pin/)}
  site_project_paths.each do |project_name|
    project_path_config[project_name] = File.join(pin_2010_path,"sites",project_name)
  end
  # apps
  app_project_paths = Dir.entries(File.join(pin_2010_path,"apps")).select{|fname|!!fname.match(/^app/)}
  app_project_paths.each do |project_name|
    project_path_config[project_name] = File.join(pin_2010_path,"apps",project_name)
  end
  PROJECT_PATH_CONFIG = project_path_config

end

