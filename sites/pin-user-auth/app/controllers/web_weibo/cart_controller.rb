class WebWeibo::CartController < ApplicationController
  before_filter :login_required

  def add
    current_user.add_status_to_cart(params[:mid])
    render :text=>200
  end

  def index
    @weibo_statuses = current_user.weibo_statuses
  end
end
