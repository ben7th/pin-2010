RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # 加载一些 公共的配置
  # 例如 gem lib
  require "#{RAILS_ROOT}/../../lib/get_all_dir"
  GetAllDir.load_config(config)
end