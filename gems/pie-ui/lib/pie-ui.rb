module PieUi
  class << self
    # 加载各个扩展
    def load_extensions      
      if defined? ActionView::Base
        require 'pie-ui/action_view_ext/xml_format_helper'
        ActionView::Base.send :include, PieUi::XmlFormatHelper

        require 'pie-ui/action_view_ext/bundle_helper'
        ActionView::Base.send :include, PieUi::BundleHelper

        require 'pie-ui/action_view_ext/mindpin_layout_helper'
        ActionView::Base.send :include, PieUi::MindpinLayoutHelper

#        require 'pie-ui/action_view_ext/avatar_helper'
#        ActionView::Base.send :include, PieUi::AvatarHelper

        require 'pie-ui/action_view_ext/datetime_helper'
        ActionView::Base.send :include, PieUi::DatetimeHelper

        require 'pie-ui/action_view_ext/dom_util_helper'
        ActionView::Base.send :include, PieUi::DomUtilHelper

        require 'pie-ui/action_view_ext/button_helper'
        ActionView::Base.send :include, PieUi::ButtonHelper

        require 'pie-ui/action_view_ext/status_page_helper'
        ActionView::Base.send :include, PieUi::StatusPageHelper

        require 'pie-ui/action_view_ext/git_commit_helper'
        ActionView::Base.send :include, PieUi::GitCommitHelper

        require 'pie-ui/action_view_ext/auto_link_helper'
        ActionView::Base.send :include, PieUi::AutoLinkHelper

        require 'pie-ui/action_view_ext/link_helper'
        ActionView::Base.send :include, PieUi::LinkHelper

        require 'pie-ui/action_view_ext/partial_helper'
        ActionView::Base.send :include, PieUi::PartialHelper

        require 'pie-ui/action_view_ext/weibo_helper'
        ActionView::Base.send :include, PieUi::WeiboHelper
      end
    end
  end
end

if defined? Rails
  PieUi.load_extensions
  Haml::Filters::CodeRay.encoder_options = {:css=>:class}
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

# pin_url_for 等方法
require "pie-ui/project_link_module"
include PieUi::ProjectLinkModule

# 字符串扩展
require 'pie-ui/string_util'

# grit初始化
require 'repo/grit_init'
Grit::Repo.send(:include,RepoInit)
Grit::Diff.send(:include,DiffInit)

# 声明邮件服务配置
if defined? ActionMailer::Base
  ActionMailer::Base.smtp_settings = {
    :address        => "mail.mindpin.com",
    :domain         => "mindpin.com",
    :authentication => :plain,
    :user_name      => "mindpin",
    :password       => "m1ndp1ngoodmail"
  }
end






