class ThumbsController < ApplicationController

  def show
    redirect_to "#{IMAGE_CACHE_SITE}/images/#{params[:id]}.#{params[:format]}?size_param=120x90"
  end

end