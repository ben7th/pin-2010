class IndexController < ApplicationController
  def index
    if !logged_in?
      return render :template=>'auth/index',:layout=>'auth'
    end
    #redirect_to pin_url_for('pin-workspace','/workspaces')
    _user_page
  end

  def _user_page
    @workspaces = current_user.workspaces
    @apps = App.all
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