class MindpinLayout
  attr_accessor :theme
  attr_accessor :grid
  attr_accessor :yield_partial
  attr_accessor :hide_nav, :hide_footer
  attr_accessor :head_class
  attr_accessor :put_js_in_head
  attr_accessor :welcome_string

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
    end
  end

end
