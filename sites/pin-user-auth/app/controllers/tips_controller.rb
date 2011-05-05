class TipsController < ApplicationController
  before_filter :login_required

  def remove_viewpoint_vote_up_tip
    UserViewpointVoteUpTipProxy.new(current_user).remove_tip_by_tip_id(params[:tip_id])
    render :text=>200
  end

  def remove_all_viewpoint_vote_up_tips
    UserViewpointVoteUpTipProxy.new(current_user).remove_all_tips
    render :text=>200
  end

  def remove_viewpoint_tip
    UserAddViewpointTipProxy.new(current_user).remove_tip_by_tip_id(params[:tip_id])
    render :text=>200
  end

  def remove_all_viewpoint_tips
    UserAddViewpointTipProxy.new(current_user).remove_all_tips
    render :text=>200
  end
end
