class ConfigManager
  def self.resque_queues
    setting = GlobalConfig::SETTING_CONFIG["resque_queues"]
    setting["resque_queues"]
  end
end
