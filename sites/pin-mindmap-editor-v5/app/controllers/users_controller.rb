class UsersController < ApplicationController
  def show
    redirect_to "/users/#{params[:id]}/mindmaps"
  end

  def cooperate
    set_cellhead_path("user_mindmaps/cellhead")
    set_tabs_path("mindmaps/tabs")
    @user = User.find(params[:id])
    @cooperate_edit_mindmaps = @user.cooperate_edit_mindmaps
    @cooperate_view_mindmaps = @user.cooperate_view_mindmaps
  end
end
