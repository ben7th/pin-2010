module PieUi
  class << self

    def enable_classes
      require 'pie-ui/classes/ui_service'
      require 'pie-ui/classes/mindpin_layout'
    end

    def enable_actionpack
      require 'pie-ui/convention'

      require 'pie-ui/helpers/mplist_helper'
      require 'pie-ui/helpers/mplist_helper_config'
      ActionView::Base.send :include, MplistHelper

      require 'pie-ui/helpers/xml_format_helper'
      ActionView::Base.send :include, XmlFormatHelper

      require 'pie-ui/helpers/bundle_helper'
      ActionView::Base.send :include, BundleHelper

      require 'pie-ui/helpers/mindpin_layout_helper'
      ActionView::Base.send :include, MindpinLayoutHelper

      require 'pie-ui/helpers/logo_helper'
      ActionView::Base.send :include, LogoHelper

      require 'pie-ui/helpers/html_dom_helper'
      ActionView::Base.send :include, HtmlDomHelper

      require 'pie-ui/helpers/datetime_helper'
      ActionView::Base.send :include, DatetimeHelper

      require 'pie-ui/helpers/login_fbox_helper'
      ActionView::Base.send :include, LoginFboxHelper

      require 'pie-ui/helpers/link_helper'
      ActionView::Base.send :include, LinkHelper

      require 'pie-ui/helpers/dom_util_helper'
      ActionView::Base.send :include, DomUtilHelper

      require 'pie-ui/helpers/button_helper'
      ActionView::Base.send :include, ButtonHelper

      require 'pie-ui/helpers/status_page_helper'
      ActionView::Base.send :include, StatusPageHelper

      require 'pie-ui/helpers/email_actor_helper'
      ActionView::Base.send :include, EmailActorHelper

      require 'pie-ui/helpers/git_commit_helper'
      ActionView::Base.send :include, GitCommitHelper

      require 'pie-ui/helpers/auto_link_helper'
      ActionView::Base.send :include, AutoLinkHelper

      ActionController::Base.send :include, MindpinLayout::ControllerFilter
    end

    def enable_ui_render
      require 'pie-ui/ui_render/controller_methods'
      require 'pie-ui/ui_render/fbox_module'
      require 'pie-ui/ui_render/mplist_module'
      require 'pie-ui/ui_render/mindpin_ui_render'
      
      ActionController::Base.send :include, ControllerMethods
    end

    def enable_form_builder
      require 'pie-ui/form_builder/mindpin_form_builder'
      require 'pie-ui/form_builder/form_helper'

      ActionView::Base.send :include, FormHelper
    end

    def auth_include_modules
      if defined? ActiveRecord::Base
        require 'pie-ui/set_readonly'
        ActiveRecord::Base.send :include, SetReadonly
        require 'pie-ui/build_database_connection'
        ActiveRecord::Base.send :include, BuildDatabaseConnection
        require 'pie-ui/save_without_timestamping'
        ActiveRecord::Base.send :include, SaveWithoutTimestamping
        require "paperclip"
        ActiveRecord::Base.send :include, Paperclip
      end
      if defined? ActionView::Base
        require "pie-ui/project_link_module"
        ActionView::Base.send :include, ProjectLinkModule
      end
      if defined? ActionController::Base
        require 'pie-ui/authenticated_system'
        ActionController::Base.send :include,AuthenticatedSystem
        require 'pie-ui/controller_filter'
        ActionController::Base.send :include,ControllerFilter
      end
    end

  end
end

if defined? Rails

  def base_layout_path(filename)
    "#{RAILS_ROOT}/../../lib/ui/base_layout/#{filename}"
  end

  def base_haml_path(filename)
    "#{RAILS_ROOT}/../../lib/ui/haml/#{filename}"
  end
  
  PieUi.auth_include_modules
  PieUi.enable_classes
  PieUi.enable_actionpack if defined? ActionController
  PieUi.enable_ui_render if defined? ActionController
  PieUi.enable_form_builder if defined? ActionController

  def Rails.production?
    Rails.env == 'production'
  end

  def Rails.development?
    Rails.env == 'development'
  end


  require "haml"
  require 'coderay'
  require 'haml-coderay'
  
  Haml::Filters::CodeRay.encoder_options = {:css=>:class}
  
end

if defined? ActiveRecord::Base
  begin
    require 'cache_money'
    require 'memcache'

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
    $memcache = MemCache.new(config)
    $memcache.servers = config[:servers]

    $local = Cash::Local.new($memcache)
    $lock = Cash::Lock.new($memcache)
    $cache = Cash::Transactional.new($local, $lock)

    p '加载工程 cache money 配置'

    class ActiveRecord::Base
      is_cached :repository => $cache
    end
  rescue Exception => ex
    p "#{ex.message}，不加载 cache money"
  end
end

if defined? ActiveRecord::Base
  begin
    p '>>>>> 加载向量缓存配置'
    require 'pie-ui/redis_cache_rule'
    ActiveRecord::Base.send :include, RedisCacheRule
  rescue Exception => ex
    p "#{ex.message}，向量缓存配置加载失败"
  end
end

if defined? ActiveRecord::Base
  begin
    p '>>>>> 加载 tip 配置'
    require 'pie-ui/tip_rule'
    ActiveRecord::Base.send :include, TipRule
  rescue Exception => ex
    p "#{ex.message}，tip 配置加载失败"
  end
end

require 'pie-ui/global_util'
include GlobalUtil
# 一些 helper 方法
include ProjectLinkModule

require 'pie-ui/string_util'

require 'pie-ui/classes/mplist_record'
require "pie-ui/patch/will_paginate_localize_and_add_ajax_link"

require "pie-ui/patch/contacts_cn_fix"

require 'repo/grit_init'
# asset_id
ENV['RAILS_ASSET_ID'] = UiService.asset_id

Grit::Repo.send(:include,RepoInit)
Grit::Diff.send(:include,DiffInit)

if defined? ActionMailer::Base
  ActionMailer::Base.smtp_settings = {
    :address => "mail.mindpin.com",
    :domain => "mindpin.com",
    :authentication => :plain,
    :user_name => "mindpin",
    :password => "m1ndp1ngood!!!"
  }
end






