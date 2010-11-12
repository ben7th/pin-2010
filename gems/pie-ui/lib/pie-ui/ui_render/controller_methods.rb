module PieUi
  module ControllerMethods
    def self.included(base)
      base.send(:include,InstanceMethods)
    end

    module InstanceMethods

      # 2月26号 新渲染器
      # 8月19号 移入gem
      def render_ui(options=nil, &block)
        if block_given?
          render :update do |page|
            context = instance_exec{@template}
            yield PieUi::MindpinUiRender.new(context,page,&block)
          end
          return
        end

        context = instance_exec{@template}
        @ui_scope_generator = []
        PieUi::MindpinUiRender.new(context,@ui_scope_generator)
      end
    end
  end
end

module ActionController
  class Base
    def render_with_ui_scope_generator(options = nil, extra_options = {}, &block)
      if @ui_scope_generator.blank?
        render_without_ui_scope_generator(options, extra_options, &block)
      else
        render_without_ui_scope_generator :update do |part|
          part << @ui_scope_generator*"\n"
        end
      end
    end
    alias_method_chain :render, :ui_scope_generator
  end
end