class IndexController < ApplicationController
  before_filter :login_required
  def index
    redirect_to "/users/#{current_user.id}"
  end
end