RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # 加载一些 公共的配置
  # 例如 gem lib
  require "#{RAILS_ROOT}/../../lib/get_all_dir"
  GetAllDir.load_config(config)
  config.gem "juggernaut"
  require "open-uri"
  # 加载 lib 目录 以及所有子目录
  config.load_paths += Dir["#{RAILS_ROOT}/lib/**/"]
  config.load_paths += %W( #{RAILS_ROOT}/app/middleware )

end
