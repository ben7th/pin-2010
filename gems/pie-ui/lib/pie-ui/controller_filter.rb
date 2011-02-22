module ControllerFilter
  CLIENT_CACHE_KEY = CoreService.find_setting_by_project_name(CoreService::USER_AUTH)["client_cache_key"]
  def self.included(base)
    base.before_filter :hold_ie6
    base.before_filter :set_client_cache_key
    base.around_filter :catch_some_exception
  end

  private

  def hold_ie6
    if /MSIE 6.0/.match(request.user_agent)
      render :template=>base_layout_path("status_page/hold_ie6.haml"),:layout => false
    end
  end

  def set_client_cache_key
    if cookies[CLIENT_CACHE_KEY].blank?
      cookies[CLIENT_CACHE_KEY] = {:value=>randstr,:expires => 30.days.from_now,:domain=>'mindpin.com'}
    end
  end

  def catch_some_exception
    yield
  rescue MemCache::MemCacheError=>mex
    render_status_page(500,"缓存服务出现异常，请尝试刷新页面。")
  rescue ActiveRecord::RecordNotFound=>arex
    render_status_page(404,"正在访问的页面不存在，或者已被删除。")
  end
end
