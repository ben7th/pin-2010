class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ApplicationMethods
  helper :all
end
