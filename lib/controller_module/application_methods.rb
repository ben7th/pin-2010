module ApplicationMethods
  def self.included(base)
    base.before_filter :change_user_name_when_need_change_name
    # 通过插件开启gzip压缩
    base.after_filter OutputCompressionFilter
    # 修正IE浏览器请求头问题
    base.before_filter :fix_ie_accept
    # 对错误显示友好的页面
    base.around_filter :catch_template_exception
  end

  def change_user_name_when_need_change_name
    if current_user
      current_user.change_name_when_need!
    end
  end

  def fix_ie_accept
    if /MSIE/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*'
      if !/.*\.gif/.match(request.url)
        request.env["HTTP_ACCEPT"] = '*/*'
      end
    end
  end


  def catch_template_exception
    yield
  rescue ActionView::TemplateError=>ex
    if RAILS_ENV == "development"
      raise ex
    else
      return render_status_page(505,ex.message)
    end
  end

end
