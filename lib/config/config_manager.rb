class ConfigManager
  def self.resque_queues
    setting = GlobalConfig::SETTING_CONFIG["resque_queues"]
    setting["resque_queues"]
  end

  def self.pin_2010_path
    GlobalConfig::PIN_2010_PATH
  end
end
