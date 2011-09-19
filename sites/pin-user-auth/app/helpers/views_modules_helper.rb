module ViewsModulesHelper

  def morender(kind,name,params={})
    begin
      render "views_modules/#{kind.pluralize}/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

  def prender(kind,name,params={})
    begin
      render "#{kind.pluralize}/parts/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

end
