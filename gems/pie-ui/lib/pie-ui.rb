module PieUi
  class << self
    
    # 加载自定义的类
    def load_classes
      require 'pie-ui/classes/ui_service'
    end

    # 加载各个扩展
    def load_extensions
      if defined? ActiveRecord::Base
        require 'pie-ui/active_record_ext/set_readonly'
        ActiveRecord::Base.send :include, PieUi::SetReadonly

        require 'pie-ui/active_record_ext/build_database_connection'
        ActiveRecord::Base.send :include, PieUi::BuildDatabaseConnection

        require 'pie-ui/active_record_ext/save_without_timestamping'
        ActiveRecord::Base.send :include, PieUi::SaveWithoutTimestamping
      end

      if defined? ActionView::Base
        require "pie-ui/action_view_ext/project_link_helper"
        ActionView::Base.send :include, PieUi::ProjectLinkHelper
      end
      
      if defined? ActionView::Base
        require 'pie-ui/action_view_ext/view_helpers/xml_format_helper'
        ActionView::Base.send :include, PieUi::XmlFormatHelper

        require 'pie-ui/action_view_ext/view_helpers/bundle_helper'
        ActionView::Base.send :include, PieUi::BundleHelper

        require 'pie-ui/action_view_ext/view_helpers/mindpin_layout_helper'
        ActionView::Base.send :include, PieUi::MindpinLayoutHelper

        require 'pie-ui/action_view_ext/view_helpers/avatar_helper'
        ActionView::Base.send :include, PieUi::AvatarHelper

        require 'pie-ui/action_view_ext/view_helpers/datetime_helper'
        ActionView::Base.send :include, PieUi::DatetimeHelper

        require 'pie-ui/action_view_ext/view_helpers/dom_util_helper'
        ActionView::Base.send :include, PieUi::DomUtilHelper

        require 'pie-ui/action_view_ext/view_helpers/button_helper'
        ActionView::Base.send :include, PieUi::ButtonHelper

        require 'pie-ui/action_view_ext/view_helpers/status_page_helper'
        ActionView::Base.send :include, PieUi::StatusPageHelper

        require 'pie-ui/action_view_ext/view_helpers/git_commit_helper'
        ActionView::Base.send :include, PieUi::GitCommitHelper

        require 'pie-ui/action_view_ext/view_helpers/auto_link_helper'
        ActionView::Base.send :include, PieUi::AutoLinkHelper
      end
    end

    def load_gems
      require "haml"
      require 'coderay'

      require 'haml-coderay'
      Haml::Filters::CodeRay.encoder_options = {:css=>:class}

      require "paperclip"
      ActiveRecord::Base.send :include, Paperclip
    end

  end
end

if defined? Rails
  PieUi.load_classes
  PieUi.load_extensions
  PieUi.load_gems

  def Rails.production?
    Rails.env == 'production'
  end

  def Rails.development?
    Rails.env == 'development'
  end  
end

# ---------------------------------------------------------------

# 加载cache_money配置
if defined? ActiveRecord::Base
  begin
    require 'memcache'
    require 'cache_money'

    memcached_config = {
      :test=>{
        :ttl=>604800,
        :namespace=>"global_test",
        :sessions=>false,
        :debug=>false,
        :servers=>"localhost:11211"
      },
      :development=>{
        :ttl=>604800,
        :namespace=>"global_development",
        :sessions=>false,
        :debug=>true,
        :servers=>"localhost:11211"
      },
      :production=>{
        :ttl=>604800,
        :namespace=>"production",
        :sessions=>false,
        :debug=>false,
        :servers=>"localhost:11211"
      }
    }
    config = memcached_config[RAILS_ENV.to_sym]

    if RAILS_ENV == "test"
      $memcache = Cash::Mock.new
      p ">>>>> 当前为测试环境，$memcache = Cash::Mock.new"
    else
      $memcache = MemCache.new(config)
    end
    
    $memcache.servers = config[:servers]

    $local  = Cash::Local.new($memcache)
    $lock   = Cash::Lock.new($memcache)
    $cache  = Cash::Transactional.new($local, $lock)

    p '>>>>> 加载 cache_money 配置'

    class ActiveRecord::Base
      is_cached :repository => $cache
    end
  rescue Exception => ex
    p "#{ex.message}，cache_money 配置加载失败"
  end
end

# 加载 mindpin_logic 配置
if defined? ActiveRecord::Base
  begin
    p '>>>>> 加载 mindpin_logic 配置'
    require 'pie-ui/mindpin_logic_rule'
    ActiveRecord::Base.send :include, MindpinLogicRule
  rescue Exception => ex
    p "#{ex.message}，mindpin_logic 配置加载失败"
  end
end

# 字符串扩展
require 'pie-ui/string_util'

# 翻页补丁
require "pie-ui/patch/will_paginate_localize_and_add_ajax_link"

# 邮箱联系人解析补丁
require "pie-ui/patch/contacts_cn_fix"

# grit初始化
require 'repo/grit_init'
Grit::Repo.send(:include,RepoInit)
Grit::Diff.send(:include,DiffInit)

# 声明 asset_id
ENV['RAILS_ASSET_ID'] = UiService.asset_id

# 声明邮件服务配置
if defined? ActionMailer::Base
  ActionMailer::Base.smtp_settings = {
    :address => "mail.mindpin.com",
    :domain => "mindpin.com",
    :authentication => :plain,
    :user_name => "mindpin",
    :password => "m1ndp1ngood!!!"
  }
end






