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
      base.layout base_layout_path('application.haml')

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
        set_cellhead_tail false
        set_tabs_path false
        @status_text = text
        @status_code = code
        render :template=>base_layout_path("status_page/status_page.haml"),:status=>code
      end

    end
  end

end
