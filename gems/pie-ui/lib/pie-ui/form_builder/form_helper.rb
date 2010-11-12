module FormHelper

  def _deal_form_args(*args)
    object_or_array = args.first
    object = object_or_array.is_a?(Array) ? object_or_array.last : object_or_array

    options = args.extract_options!.merge(:builder => MindpinFormBuilder)
    options[:html] ||= {}

    css_classes = options[:html][:class] || ''

    html_options =
      if object.respond_to?(:new_record?) && object.new_record?
        { :class  => "common_form #{dom_class(object, :new)} #{css_classes}" }
      else
        { :class  => "common_form #{dom_class(object, :edit)} #{css_classes}" }
      end

    options[:html].merge!(html_options)
    
    options
  end

  def mindpin_form_for(*args, &block)
    options = _deal_form_args(*args)
    form_for(*(args + [options]), &block)
  end

  def mindpin_remote_form_for(*args, &block)
    options = _deal_form_args(*args)
    remote_form_for(*(args + [options]), &block)
  end

  def mindpin_remote_fbox_form_for(*args, &block)
    sending_data_dom_id = randstr

    options = _deal_form_args(*args)
    options[:loading] = options[:loading] || ''
    options[:loading] = 
      "jQuery('##{sending_data_dom_id}').removeClass('hide');" + options[:loading]

    part1 = flash_info
    part2 = "<span id='#{sending_data_dom_id}' class='sending_data hide'>正在处理数据，请稍候...</span>"
    concat(part1)
    concat(part2)
    remote_form_for(*(args + [options]), &block)
  end

  def flash_info
    re = []
    [:notice,:error,:success].each do |kind|
      msg = flash[kind]
      re << "<div class='flash-#{kind}'>#{_pack_flash_msg(msg)}</div>" if msg
    end
    re*''
  end
  
  def _pack_flash_msg(msg)
    "<span>#{msg}</span>"
  end
end
