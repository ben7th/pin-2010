# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationMethods
  helper :all

  protect_from_forgery

  around_filter :catch_oauth_exception
  def catch_oauth_exception
    yield
  rescue Tsina::OauthFailureError=>tsina_error
    if request.xhr?
      return render :text=>tsina_error.message,:status=>503
    else
      return render_status_page(503,tsina_error.message)
    end
  end

end