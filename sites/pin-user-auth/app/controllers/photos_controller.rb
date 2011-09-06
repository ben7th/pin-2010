class PhotosController < ApplicationController
  before_filter :per_load
  skip_before_filter :verify_authenticity_token,:only=>[:feed_upload]
  before_filter :verify_authenticity_token_by_client,:only=>[:feed_upload]
  def per_load
    @photo = Photo.find(params[:id]) if params[:id]
  end
  
  def verify_authenticity_token_by_client
    verify_authenticity_token unless is_android_client?
  end

  def create
    photo = current_user.create_photo_or_find_by_file_md5(params[:file])
    unless photo.id.blank?
      return render :partial=>'modules/photos/photo_manage',:locals=>{:photos=>[photo]}
    end
    render :json=>{:message=>photo.errors.first[1]},:status=>402
  end

  def feed_upload
    @image_file_name = PhotoAdpater.create_by_upload_file(params[:file])
    @image_url = PhotoAdpater.thumb_url_by_image_file_name(@image_file_name)
    unless is_android_client?
      render :partial=>'modules/photos/feed_uploaded',
        :locals=>{:url=>@image_url,:name=>@image_file_name}
    else
      render :text=>@image_file_name
    end
  rescue Magick::ImageMagickError => ex
    render :text=>"请上传图片",:status=>500
  end

  def show
  end

  def destroy
    @photo.destroy
    redirect_to "/entries"
  end

  def comments
    comment = @photo.comments.create(:user=>current_user,:content=>params[:content])
    redirect_to :action=>:show
  end

  def add_description
    if logged_in? && current_user == @photo.user
      @photo.update_attribute(:description,params[:description])
    end
    redirect_to :action=>:show
  end

  def send_feed
  end

  def create_feed
    feed = current_user.send_feed(params[:content],:detail=>"",:tags=>"",:sendto=>"all-public",:photo_ids=>@photo.id.to_s)
    if feed.id.blank?
      flash[:error]=get_flash_error(feed)
      return redirect_to "/photos/#{@photo.id}/send_feed"
    end
    redirect_to "/photos/#{@photo.id}"
  end

end