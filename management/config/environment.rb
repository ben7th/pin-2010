RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "redis"

  require "#{RAILS_ROOT}/../lib/get_all_dir"
  config.load_paths += GetAllDir.get_all_dir("#{RAILS_ROOT}/../lib/management")
  config.load_paths += GetAllDir.get_all_dir("#{RAILS_ROOT}/../lib/config")

  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.time_zone = 'UTC'

  config.i18n.default_locale = :cn
end