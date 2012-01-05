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
    load_codes
    load_config
    
    require 'digest/sha1'
    
    require File.join(MINDPIN_LIB_PATH, 'mindpin_global_methods.rb')
  end

  private
  def load_codes
    # 加载公共代码
    @config.autoload_paths += Dir["#{AUTO_LOADS_PATH}/**/"]

    # 当前工程的lib
    @config.autoload_paths += Dir["#{Rails.root}/lib/**/"]

    # 当前工程的middleware
    @config.autoload_paths += ["#{Rails.root}/app/middleware/"]
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
