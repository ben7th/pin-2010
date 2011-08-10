class EntriesController < ApplicationController
  def index
    @photos = current_user.photos.paginate(:per_page=>20,:page=>params[:page]||1)
    render :template=>"entries/index"
  end

  def photos
    index
  end
end