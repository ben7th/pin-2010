class PhotosController < ApplicationController
  before_filter :per_load
  def per_load
    @photo = Photo.find(params[:id]) if params[:id]
  end

  def create
    photo = current_user.photos.create(:image=>params[:file])
    unless photo.id.blank?
      return render :partial=>'modules/photos/photo_manage',:locals=>{:photos=>[photo]}
    end
    render :json=>{:message=>photo.errors.first[1]},:status=>402
  end

  def feed_upload
    photo = current_user.photos.create(:image=>params[:file])
    unless photo.id.blank?
      return render :partial=>'modules/photos/feed_uploaded',:locals=>{:photos=>[photo]}
    end
    render :text=>"上传失败",:status=>402
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