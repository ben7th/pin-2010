class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ApplicationMethods
  helper :all
  protect_from_forgery

  before_filter :hold_no_university_user
  def hold_no_university_user
    if logged_in? && !current_user.has_university?
      if ![
        ["profiles","new"],
        ["profiles","create"]
      ].include?([params[:controller],params[:action]])
        redirect_to "/profile/new"
      end
    end
    return true
  end
end
