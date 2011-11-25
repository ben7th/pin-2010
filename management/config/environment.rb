RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "haml"
  config.gem "redis"

  config.autoload_paths += Dir["#{RAILS_ROOT}/lib/**/"]

  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  config.time_zone = 'UTC'

  config.i18n.default_locale = :cn
end