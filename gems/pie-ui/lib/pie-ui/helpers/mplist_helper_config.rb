module PieUi
  class MplistHelperConfig
    include PieUi::Convention
    include PieUi::MplistPartialMethods

    attr_reader :context
    attr_reader :collection
    attr_reader :options

    def initialize(controller_template,collection,options={})
      @context = instance_exec{controller_template}
      @collection = collection
      @options = options
    end

    def object_classname
      @for_classname ||= get_mplist_for_object_classname(options[:for])
    end

    def selectable
      @selectable ||= !!options[:selectable]
    end

    def classname
      @classname ||= ['mplist',options[:class],object_classname].compact*' '
    end

    def html_dom_id
      @html_dom_id ||= "mplist_#{options[:id] || build_ul_id(options[:for]) || randstr}"
    end

    def partial_locals
      @partial_locals ||= (options[:locals] || {})
    end

    def partial_locals_of(model)
      {get_sym_of(model)=>model}.merge(partial_locals)
    end

    def partial
      @partial ||= options[:partial]
    end

    def partial_of(model)
      partial || get_partial_name_of_model(model)
    end

    def partial_configs_of(model)
      {:partial=>partial_of(model),:locals=>partial_locals_of(model)}
    end

    def li_classname
      'mpli'
    end

    def li_tag_html(model, &block)
      case model
        when ActiveRecord::Base, MplistRecord
          @context.content_tag_for(:li, model, :class=>li_classname) {
            _li_tag_innerhtml(model, &block)
          }
        when nil
          raise 'mplist 构建器被传入了 nil 对象'
        else
          raise '传入 mplist 构建器的对象不是 ActiveRecord::Base 或 MplistRecord'
      end
    end

    def _li_tag_innerhtml(model, &block)
      return @context.capture(model, &block) if block_given?
      return (@context.render partial_configs_of(model))
    end

#    # 去掉末尾的 \n 的目的是为了输出代码的整齐
#    def _fix_capture_tail_format(capture_str)
#      capture_str.sub(/\n$/,'')
#    end

    def ul_html(&block)
      [
        "<ul id='#{html_dom_id}' class='#{classname}' data-selectable='#{selectable}'>",
        @collection.map {|model| li_tag_html(model, &block)}*'',
        "</ul>"
      ]*''
    end

  end
end