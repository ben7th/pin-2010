class FeedRevisionsController < ApplicationController
  before_filter :pre_load
  def pre_load
    @feed = Feed.find(params[:feed_id]) if params[:feed_id]
  end

  def index
  end
end
