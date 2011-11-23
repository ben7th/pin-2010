class PhotosController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only=>[:upload_for_feed]

  def upload_for_feed
    photo = PhotoAdpater.create_photo_by_upload_file(current_user, params[:file])
    
    render :partial => 'views_modules/photos/feed_uploaded',
           :locals  => {:photo=>photo}
#  rescue Exception=>ex
#    render :text=>"上传出错 #{ex}", :status=>500
  end
  
end