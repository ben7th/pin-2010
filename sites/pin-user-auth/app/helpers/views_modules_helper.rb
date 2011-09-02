module ViewsModulesHelper

  def morender(kind,name)
    begin
      render "views_modules/#{kind.pluralize}/#{name}"
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

  def prender(name,params={})
    begin
      render "#{controller.controller_name}/parts/#{name}",params
    rescue Exception => ex
      "<div class='render-error'>错误：#{ex}</div>"
    end
  end

end
