module ButtonHelper
  def minibutton_remote(name, options = {}, html_options = {}, &block)
    link_to_remote("<span>#{name}</span>",options,html_options.merge({:class=>'minibutton'}),&block)
  end

  def minibutton(name, url, options = {}, &block)
    link_to("<span>#{name}</span>",url,options.merge({:class=>'minibutton'}),&block)
  end
end
