class GetAllDir
  require "find"
  def self.get_all_dir(basedir)
    dirs = []
    Find.find(basedir) do |path|
      if FileTest.directory?(path)
        dirs << path
      end
    end
    dirs
  end

  def self.load_config(config)
    # 加载常用的一些 gem
    config.gem "mislav-will_paginate", :version => '2.3.11', :source => "http://gems.github.com/", :lib => "will_paginate"
    config.gem "haml"
    config.gem "redis"
    config.gem "pacecar"
    config.gem "contacts_cn"
    config.gem "oauth"
    config.gem "uuidtools"
    config.gem "responds_to_parent"
    config.gem "rubyzip", :version => '0.9.4', :lib => "zip/zip"
    # 自己写的 gem
    config.gem "pie-ui"
    # 加载 公共 lib
    config.load_paths += GetAllDir.get_all_dir(File.dirname(File.expand_path(__FILE__)))
    # 时区  和 国际化
    config.time_zone = 'UTC'
    config.i18n.default_locale = :cn
    # ap 是 p 的增强版
    require "ap"
  end
end
