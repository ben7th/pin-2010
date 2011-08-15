class MindpinLayout
  attr_accessor :theme
  attr_accessor :grid
  attr_accessor :yield_partial
  attr_accessor :hide_nav, :hide_footer
  attr_accessor :head_class
  attr_accessor :put_js_in_head
  attr_accessor :welcome_string
  attr_accessor :tabs_path
  attr_accessor :cellhead_tail
  attr_accessor :cellhead_path

  module ControllerFilter
    def self.included(base)   
      base.send(:include,InstanceMethods)
      base.before_filter :init_layout
    end

    module InstanceMethods
      def init_layout
        @mindpin_layout = MindpinLayout.new
        return true
      end

      def set_tabs_path(path)
        @mindpin_layout.tabs_path = path
      end

      def set_cellhead_path(path)
        @mindpin_layout.cellhead_path = path
      end

      def set_cellhead_tail(tail)
        @mindpin_layout.cellhead_tail = tail
      end

      def render_status_page(code,text='')
        flash.now[:status_text] = text
        flash.now[:status_code] = code
        render "layouts/status_page/status_page",:status=>code
      end

    end
  end

end
