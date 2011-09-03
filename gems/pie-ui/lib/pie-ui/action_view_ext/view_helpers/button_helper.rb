module PieUi
  module ButtonHelper
    def minibutton(name, url, options = {}, &block)
      klass = {:class=>['minibutton',options[:class]]*' '}
      link_to("<span>#{name}</span>",url,options.merge(klass),&block)
    end
  end
end