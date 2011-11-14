class IndexController < ApplicationController
  def index
    unless logged_in?
      return redirect_to pin_url_for("pin-auth","/login")
    end
  end
end