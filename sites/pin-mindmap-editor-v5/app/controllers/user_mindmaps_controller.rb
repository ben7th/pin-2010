class UserMindmapsController < ApplicationController
  before_filter :per_load
  def per_load
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  include MindmapFindingControllerMethods

  # GET users/:user_id/mindmaps
  def index
    set_tabs_path('mindmaps/tabs')
    @mindmaps = get_mindmaps_of_user(@user)
    @mapdata = get_mapdata_of_user(@user)
    @can_create_map = is_current_user?(@user)
    @newbie = (@can_create_map && @mindmaps.blank?)
  end
end
