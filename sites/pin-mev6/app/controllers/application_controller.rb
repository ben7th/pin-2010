# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationMethods
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :fix_ie_accept
  # 修正IE浏览器请求头问题
  def fix_ie_accept
    if /MSIE/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*'
      if !/.*\.gif/.match(request.url)
        request.env["HTTP_ACCEPT"] = '*/*'
      end
    end
  end
end
