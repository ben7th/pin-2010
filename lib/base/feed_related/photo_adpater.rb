class PhotoAdpater
  if RAILS_ENV == "development"
    ATTACHED_FILE_PATH_ROOT = "/web1/2010/upload_photo_tempfile"
  else
    ATTACHED_FILE_PATH_ROOT = "/web/2010/upload_photo_tempfile"
  end

  # 返回 image_file_name
  def self.create_by_upload_file(file)
    pt = PhotoTmp.create!(:image=>file)
    pt.id
  end

  def self.url_by_image_file_name(image_file_name)
    PhotoTmp.find(image_file_name).image.url
  end

  def self.thumb_url_by_image_file_name(image_file_name)
    PhotoTmp.find(image_file_name).image.url(:s66)
  end

  def self.path_by_image_file_name(image_file_name)
    PhotoTmp.find(image_file_name).image.path
  end

  def self.thumb_path_by_image_file_name(image_file_name)
    PhotoTmp.find(image_file_name).image.path(:s66)
  end

  def self.create_photo_by_file_name(image_file_name,user)
    photo_tmp = PhotoTmp.find(image_file_name)
    photo = Photo.new(:user=>user,:skip_resize_image=>true)
    photo.send(:create_without_callbacks)
    photo.md5 = photo_tmp.md5
    photo.image_content_type = photo_tmp.image_content_type
    photo.image_file_size = photo_tmp.image_file_size
    photo.image_updated_at = photo_tmp.image_updated_at
    photo.image_file_name = photo_tmp.image_file_name
    photo.send(:update_without_callbacks)
    FileUtils.cp_r(photo_tmp.image_base_path,photo.image_base_path)
    Photo.find(photo.id)
  end

end
