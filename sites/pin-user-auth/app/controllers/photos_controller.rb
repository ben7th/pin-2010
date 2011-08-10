class PhotosController < ApplicationController
  def create
    photo = current_user.photos.create(:image=>params[:file])
    unless photo.id.blank?
      return render :text=>"上传成功"
    end
    render :text=>"上传失败",:status=>402
  end

  def feed_upload
    photo = current_user.photos.create(:image=>params[:file])
    unless photo.id.blank?
      return render :partial=>'modules/photos/feed_uploaded',:locals=>{:photos=>[photo]}
    end
    render :text=>"上传失败",:status=>402
  end

end