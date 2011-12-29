class WebWeibo::CartController < ApplicationController
  before_filter :login_required
  layout 'fullscreen'

  def add
    current_user.add_status_to_cart(params[:mid])
    render :text=>200
  end

  def index
    @statuses = current_user.weibo_statuses.map{|status| status.mash}
  end
end
