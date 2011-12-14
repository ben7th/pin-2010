class UsersController < ApplicationController
  before_filter :per_load
  def per_load
    @user = User.find(params[:id]) if params[:id]
  end

  def show
    if logged_in? && @user == current_user
      @mindmaps = @user.mindmaps.paginate(:per_page=>20, :page=>params[:page]||1)
    else
      @mindmaps = @user.mindmaps.publics.paginate(:per_page=>20, :page=>params[:page]||1)
    end
  end

end
