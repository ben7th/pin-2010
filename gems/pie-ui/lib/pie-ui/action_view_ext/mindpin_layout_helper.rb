module PieUi
  module MindpinLayoutHelper
    # 用于其他子工程，引用公共ui
    def require_ui_css
      stylesheet_link_tag UiService.css_files
    end

    def require_lib_js
      javascript_include_tag UiService.js_lib_files
    end

    def require_mindpin_js
      javascript_include_tag UiService.js_files
    end

    def htitle(title)
      content_for :title do
        title
      end
    end
  end
end
