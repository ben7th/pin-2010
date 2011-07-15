class UserAvatarAdpater
  if RAILS_ENV == "development"
    ATTACHED_FILE_PATH_ROOT = "/web1/2010/upload_user_avatar_tempfile"
  else
    ATTACHED_FILE_PATH_ROOT = "/web/2010/upload_user_avatar_tempfile"
  end

  # 返回 image_file_name
  def self.create_by_upload_file(file)
    upload_temp_id = randstr

    file_name = file.original_filename
    # 存储上传的文件
    image_file_name = "#{upload_temp_id}.#{self.file_type_by_filename(file_name)}"
    save_path = self.path_by_image_file_name(image_file_name)

    basedir = File.dirname(save_path)
    FileUtils.mkdir_p(basedir) unless File.exist?(basedir)

    FileUtils.cp(file.path,save_path)
    File.chmod(0777,save_path)

    image_file_name
  end

  def self.url_by_image_file_name(image_file_name)
    pin_url_for("ui","upload_user_avatar_tempfile/#{image_file_name}")
  end

  def self.path_by_image_file_name(image_file_name)
    File.join(ATTACHED_FILE_PATH_ROOT,image_file_name)
  end

  def self.file_type_by_filename(filename)
    name_splits = filename.split(".")
    name_splits.pop || "jpg"
  end

end
