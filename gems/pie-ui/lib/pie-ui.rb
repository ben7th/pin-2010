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
  end
end

require 'rubygems'
require 'grit'

if defined? Rails
  def base_layout_path(filename)
    "#{File.dirname(__FILE__)}/pie-ui/base_layout/#{filename}"
  end
  
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

require 'pie-ui/global_util'
include GlobalUtil

require 'pie-ui/string_util'

require 'pie-ui/classes/mplist_record'

ENV['RAILS_ASSET_ID'] = UiService.asset_id