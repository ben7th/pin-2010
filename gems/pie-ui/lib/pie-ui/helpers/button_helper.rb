module ButtonHelper
  def minibutton_remote(name, options = {}, html_options = {}, &block)
    klass = {:class=>['minibutton',options[:class]]*' '}
    link_to_remote("<span>#{name}</span>",options,html_options.merge(klass),&block)
  end

  def minibutton(name, url, options = {}, &block)
    klass = {:class=>['minibutton',options[:class]]*' '}
    link_to("<span>#{name}</span>",url,options.merge(klass),&block)
  end

  def minibutton_link_to(name, url, options = {}, &block)
    minibutton(name, url, options = {}, &block)
  end

  def classybutton(name, url, options = {}, &block)
    link_to("<span>#{name}</span>",url,options.merge({:class=>'button classy'}),&block)
  end

  def dangerbutton(name, url, options = {}, &block)
    link_to("<span>#{name}</span>",url,options.merge({:class=>'button classy danger'}),&block)
  end
end
