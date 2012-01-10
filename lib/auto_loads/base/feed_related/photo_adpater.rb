class PhotoAdpater
  ATTACHED_FILE_PATH_ROOT = "/web/2010/upload_photo_tempfile"

  # 根据 file 创建 photo
  def self.create_photo_by_upload_file(user, file)
    photo = Photo.create!(:user=>user, :image=>file)
    return photo
  end
end
