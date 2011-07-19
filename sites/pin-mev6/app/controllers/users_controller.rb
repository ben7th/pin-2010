class UsersController < ApplicationController
  before_filter :per_load
  def per_load
    @user = User.find(params[:id]) if params[:id]
  end

  def show
    @mindmaps = Mindmap.of_user_id(@user.id).
      publics.find(:all,:order=>"id desc").
      paginate(:per_page=>20,:page=>params[:page]||1)
  end

end
