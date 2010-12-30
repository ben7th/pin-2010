# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")[RAILS_ENV]
USER_API_SITE = APP_CONFIG['USER_API_SITE']
API_SITE = APP_CONFIG['API_SITE']
SHARE_API_SITE = APP_CONFIG['SHARE_API_SITE']
SECRET_KEY = APP_CONFIG['SECRET_KEY']
THIS_SITE = APP_CONFIG['THIS_SITE']
APP_PREFIX = APP_CONFIG['APP_PREFIX']
ATTACHED_FILE_PATH_ROOT = APP_CONFIG['ATTACHED_FILE_PATH_ROOT']
ATTACHED_FILE_URL_ROOT = APP_CONFIG['ATTACHED_FILE_URL_ROOT']
IMAGE_CACHE_SITE = APP_CONFIG['IMAGE_CACHE_SITE']
WORKSPACE_SITE = APP_CONFIG['WORKSPACE_SITE']
DISCUSSION_SITE = APP_CONFIG['DISCUSSION_SITE']
SERVICE_KEY = APP_CONFIG['SERVICE_KEY']

URL_PREFIX = "#{API_SITE}/#{APP_PREFIX}"

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "mislav-will_paginate", :version => '2.3.11', :source => "http://gems.github.com/", :lib => "will_paginate"
  config.gem "rubyzip", :version => '0.9.4', :lib => "zip/zip"
  config.gem "haml"
  config.gem "nokogiri"
  config.gem "paperclip"
  config.gem "uuidtools"
  config.gem "responds_to_parent"

  config.gem "pie-auth"
  config.gem "pie-ui"
  config.gem "pie-service-lib"
  config.gem "pie-repo"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.load_paths += %W( #{RAILS_ROOT}/lib/controller_helper )
  config.load_paths += %W( #{RAILS_ROOT}/lib/mindmap_module )
  config.load_paths += %W( #{RAILS_ROOT}/lib/mindmap_lucene_search )

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :cn
end