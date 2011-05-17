class TipsController < ApplicationController
  before_filter :login_required

  def remove_user_tip
    UserTipProxy.new(current_user).remove_tip_by_tip_id(params[:tip_id])
    render :text=>200
  end

  def remove_all_user_tips
    UserTipProxy.new(current_user).remove_all_tips
    render :text=>200
  end
end
