# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  before_filter :fix_ie6_accept

  helper :all # include all helpers, all the time
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e4f6dce846118c1bf7c0f7b38b1bd3c2'

  private

  # 修正IE6浏览器请求头问题
  def fix_ie6_accept
    if /MSIE 6/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*'
      if !/.*\.gif/.match(request.url)
        request.env["HTTP_ACCEPT"] = '*/*'
      end
    end
  end

  include MindmapRightsHelper
  before_filter :claim_nobody_mindmap_from_current_cookies
  def claim_nobody_mindmap_from_current_cookies
    if current_user
      mindmap_ids = get_nobody_mindmap_ids_from_cookies
      mindmap_ids.each do |id|
        mindmap = Mindmap.find_by_id(id)
        if mindmap && mindmap.user_id == 0
          mindmap.user = current_user
          mindmap.save
        end
      end
      clear_nobody_mindmap_ids_from_cookies
    end
  end

end