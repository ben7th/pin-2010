class UsersController < ApplicationController
  def show
    id = params[:id]
    redirect_to "/users/#{id}/mindmaps"
  end
end
