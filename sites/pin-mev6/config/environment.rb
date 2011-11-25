RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # 加载公共配置
  require "#{RAILS_ROOT}/../../lib/mindpin_rails_loader"
  MindpinRailsLoader.new(config).load
  
  config.gem "google-search"
end
