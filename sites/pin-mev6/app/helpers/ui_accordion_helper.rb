module UiAccordionHelper
  def accordion_bar(*args,&block)
    options = args.extract_options!
    @mpaccordion_bar_context_arr = []
    @accordion_bar_options = AccordionbarOptions.new(options)

    block.call()

    id_str = @accordion_bar_options.id.blank? ? "" : "id='#{@accordion_bar_options.id}'"

    bar_str = %`  <div #{id_str} class="mpaccordion-bar">  `
    @mpaccordion_bar_context_arr.each do |accordion_item_options|
      bar_str << %`
        <div class="mpaccordion-toggler #{accordion_item_options.open_class}" #{accordion_item_options.bgc_style_attribute} #{accordion_item_options.data_active_bgc_attribute} #{accordion_item_options.data_bgc_attribute}>
          #{accordion_item_options.title}
        </div>
      `

      bar_str << %`
        <div class="mpaccordion-content" #{accordion_item_options.height_style_attribute}>
          #{accordion_item_options.content}
        </div>
      `
    end
    bar_str << "</div>"

    concat(bar_str)
  end

  def accordion_item(*args,&block)
    title = args.first
    options = args.extract_options!
    content = capture(&block) if block

    accordion_item_options = AccordionItemOptions.new(title,content,@accordion_bar_options,options)
    
    @mpaccordion_bar_context_arr << accordion_item_options
  end
end

class AccordionbarOptions
  def initialize(options)
    @options = options
  end

  def id
    @options[:id] || ""
  end

  def active_bgc
    @options[:active_bgc] || ""
  end

  def bgc
    @options[:bgc] || ""
  end
end

class AccordionItemOptions
  def initialize(title,content,accordion_bar_options,options)
    @title = title
    @content = content
    @accordion_bar_options = accordion_bar_options
    @options = options
  end

  def title
    @title
  end

  def content
    @content
  end

  def active_bgc
   @options[:active_bgc] || @accordion_bar_options.active_bgc || ""
  end

  def bgc
    @options[:bgc] || @accordion_bar_options.bgc || ""
  end

  def open
    @options[:open].nil? ? true : options[:open]
  end

  def open_class
    open ? "open" : "close"
  end

  def data_active_bgc_attribute
    active_bgc.blank? ? "" : "data-active-bgc='#{active_bgc}'"
  end

  def data_bgc_attribute
    bgc.blank? ? "" : "data-bgc='#{bgc}'"
  end

  def bgc_style_attribute
    bgc_str = bgc.blank? ? "" : "style='background-color:#{bgc};'"
    active_bgc_str = active_bgc.blank? ? "" : "style='background-color:#{active_bgc};'"

    open ? active_bgc_str : bgc_str
  end

  def height_style_attribute
    open ? "" : "style='height:0px;'"
  end

end
