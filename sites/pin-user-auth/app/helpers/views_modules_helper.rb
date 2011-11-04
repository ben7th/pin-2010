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

  def render_with_error_msg(err_message, path, params={})
    begin
      render path, params
    rescue Exception => ex
      return "<div class='render-error'>错误：#{ex}</div>"          if RAILS_ENV=='development'
      return "<div class='render-error'>错误：#{err_message}</div>" if RAILS_ENV=='production'
    end
  end

end
