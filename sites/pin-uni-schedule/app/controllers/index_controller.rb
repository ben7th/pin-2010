class IndexController < ApplicationController
  def index
    unless logged_in?
      return redirect_to pin_url_for("pin-user-auth","/login")
    end
    @course_items_hash = current_user.course_items_hash
  end
end