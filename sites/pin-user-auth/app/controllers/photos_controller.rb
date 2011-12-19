class PhotosController < ApplicationController
  before_filter :login_required

  def upload_for_feed
    photo = PhotoAdpater.create_photo_by_upload_file(current_user, params[:file])
    
    render :partial => 'views_modules/photos/feed_uploaded',
           :locals  => {:photo=>photo}
  rescue Exception=>ex
    render :text=>"上传出错 #{ex}", :status=>500
  end

  def import_image_url
    file = HttpUtil.get_tempfile_by_url(params[:imgsrc])
    photo = PhotoAdpater.create_photo_by_upload_file(current_user, file)
    
    feed = current_user.send_feed(
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_ids      => "#{photo.id}",
      :collection_ids => params[:collection_ids],
      :from           => Feed::FROM_WEB,
      :send_tsina     => params[:send_tsina],
      :draft_token    => params[:draft_token]
    )

    if feed.id.blank?
      render :text=>"主题保存错误",:status=>503
    end
    render :text=>"保存成功"
  rescue ActiveRecord::RecordInvalid => ex1
    render :text=>"图片保存错误",:status=>503
  rescue Exception => ex2
    render :text=>"图片地址无法获取",:status=>503
  end


end