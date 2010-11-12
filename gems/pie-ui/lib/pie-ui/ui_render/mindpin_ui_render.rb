module PieUi
  class MindpinUiRender
    include PieUi::Convention
    include PieUi::MplistPartialMethods

    include PieUi::FboxModule
    include PieUi::MplistModule

    def initialize(context,page,&block)
      @page = page # rjs 的调用句柄
      @context = context # controller上下文实例
      @controller = @context.instance_exec{@controller} # controller实例
    end

    attr_reader :page
    attr_reader :context
    attr_reader :controller

    def render(*args)
      context.render(*args)
    end

    def js(string)
      @page << string
      return self
    end

    private
      # 根据传入参数获得包含action和controller的hash
      # {:action=>"create", :controller=>"text_entries"}
      def recognize_path(url,options)
        ActionController::Routing::Routes.recognize_path(url,options)
      end

  end

end