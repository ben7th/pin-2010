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
