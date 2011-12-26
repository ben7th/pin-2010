class MindpinRailsLoader
  MINDPIN_LIB_PATH   = File.dirname(File.expand_path(__FILE__)) # ~ pin-2010/lib
  MINDPIN_PATH       = File.join(MINDPIN_LIB_PATH, '..')

  MINDPIN_SITES_PATH = File.join(MINDPIN_PATH, 'sites')

  # ------------------

  AUTO_LOADS_PATH    = File.join(MINDPIN_LIB_PATH, 'auto_loads')
  INITIALIZERS_PATH  = File.join(MINDPIN_LIB_PATH, 'initializers')
  TASKS_PATH         = File.join(MINDPIN_LIB_PATH, 'tasks')

  def initialize(config)
    @config = config
  end

  def load
    require 'memcache'
    require 'ap' # gem awesome_print

    load_gems
    load_codes
    load_config

    require File.join(MINDPIN_LIB_PATH, 'mindpin_global_methods.rb')
  end

  private

  # 加载常用的一些 gem
  def load_gems
    @config.gem 'will_paginate',
      :version => '2.3.11'

    @config.gem 'haml'
    @config.gem 'redis'
    @config.gem 'pacecar'
    @config.gem 'contacts_cn' # 此gem依赖 hpricot
    @config.gem 'nokogiri'
    @config.gem 'oauth'
    @config.gem 'uuidtools'
    @config.gem 'responds_to_parent'

    @config.gem 'rubyzip',
      :version => '0.9.4',
      :lib     => 'zip/zip'

    # resque的引入
    @config.gem 'resque'

    # markdown 解析器
    @config.gem 'redcarpet'

    # paperclip
    @config.gem 'paperclip',
      :version => "~> 2.4"
    @config.gem 'paperclip-meta'

    @config.gem 'weibo'

    # 自己写的 gem
    @config.gem "pie-ui"
    # http client
#    @config.gem "patron"
  end

  def load_codes
    # 加载公共代码
    @config.autoload_paths += Dir["#{AUTO_LOADS_PATH}/**/"]

    # 当前工程的lib
    @config.autoload_paths += Dir["#{RAILS_ROOT}/lib/**/"]

    # 当前工程的middleware
    @config.autoload_paths += ["#{RAILS_ROOT}/app/middleware/"]
  end

  def load_config
    # 时区，国际化
    @config.time_zone = 'UTC'
    @config.i18n.default_locale = :cn
  end

  # 加载补丁
  def self.load_initializers
    Dir[
      File.join(INITIALIZERS_PATH, "**", "*.rb")
    ].sort.each { |patch|
      require(patch)
    }
  end

  # 加载rake任务
  def self.load_tasks
    Dir[
      File.join(TASKS_PATH, "../tasks", "**", "*.rb")
    ].sort.each { |patch|
      require(patch)
    }
  end
end
