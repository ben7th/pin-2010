RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # 加载公共配置
  require "#{Rails.root}/../../lib/mindpin_rails_loader"
  MindpinRailsLoader.new(config).load
  
  config.gem "juggernaut"
  require "open-uri"
end
