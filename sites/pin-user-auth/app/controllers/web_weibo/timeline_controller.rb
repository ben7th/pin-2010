class WebWeibo::TimelineController < ApplicationController
  before_filter :login_required
  layout 'fullscreen'

  def home_timeline
  end

  def user_timeline
  end
end
