class FollowsController < ApplicationController
  before_filter :per_load

  def index
  end

  def per_load
    @user = User.find(params[:user_id]) if params[:user_id]
  end
end