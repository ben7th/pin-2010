module ButtonHelper
  
  def minibutton(name, url, options = {}, &block)
    klass = {
      :class => ['minibutton', options[:class]]*' '
    }
    link_to(content_tag(:span, name), url, options.merge(klass), &block)
  end
  
end