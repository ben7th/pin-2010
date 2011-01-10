class IndexController < ApplicationController
  def index
    if !logged_in?
      return render :template=>'auth/index',:layout=>'auth'
    end
    _user_page
  end

  def _user_page
    @workspaces = current_user.workspaces
    @organizations = Organization.of_user(current_user)
    @mindmaps = current_user.mindmaps
    @contacts = current_user.contacts
  end

  def updating
   redirect_to '/updating.html',:status=>301
  end

  def dev
    render_ui do |ui|
      ui.fbox :show,:title=>'bucuo',:partial=>'index/dev'
    end
  end

end