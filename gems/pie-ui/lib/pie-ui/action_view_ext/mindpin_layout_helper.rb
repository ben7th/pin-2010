module PieUi
  module MindpinLayoutHelper

    def _rails_asset_id
      ENV['RAILS_ASSET_ID']
    end

    # 用于其他子工程，引用公共ui
    def require_ui_css
      case RAILS_ENV
      when 'development'
        stylesheet_link_tag [
          pin_url_for('ui',"stylesheets/all.css?#{_rails_asset_id}")
        ]
      when 'production'
        stylesheet_link_tag [
          pin_url_for('ui',"stylesheets/all_packed.css?#{_rails_asset_id}")
        ]
      end
      
    end

    def require_lib_js
      javascript_include_tag [
        pin_url_for('ui',"javascripts/lib/jquery/jquery-1.6.1.min.noconflict.js?#{_rails_asset_id}")
      ]
    end

    def require_lin_js_with_prototype
      javascript_include_tag [
        pin_url_for('ui',"javascripts/lib/prototype/protoaculous.1.8.3.min.js?#{_rails_asset_id}"),
        pin_url_for('ui',"javascripts/lib/jquery/jquery-1.6.1.min.noconflict.js?#{_rails_asset_id}")
      ]
    end

    def require_mindpin_js
      javascript_include_tag [
        pin_url_for('ui',"javascripts/bundle_base.js?#{_rails_asset_id}")
      ]
    end

    def htitle(title)
      content_for :title do
        title
      end
    end

    def hjavascript(path)
      content_for :javascript do
        javascript_include_tag path
      end
    end

    def hcss(path)
      content_for :css do
        stylesheet_link_tag path
      end
    end
  end
end
