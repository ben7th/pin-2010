class UserAvatarAdpater
  
  if RAILS_ENV == "development"
    TEMP_FILE_BASE_DIR = "/web1/2010/upload_user_avatar_tempfile"
  else
    TEMP_FILE_BASE_DIR = "/web/2010/upload_user_avatar_tempfile"
  end

  def initialize(user, raw_file)
    @raw_file = raw_file

    user_id_str = user.id.to_s
    @temp_file_dir  = File.join(TEMP_FILE_BASE_DIR, user_id_str)
    @temp_file_name = File.join(@temp_file_dir, 'avatar_tmp')

    @temp_file_url  = pin_url_for("ui","upload_user_avatar_tempfile/#{user_id_str}/avatar_tmp")
  end

  # 存储上传的头像文件到一个临时文件中，并返回该文件 路径+名
  def create_temp_file
    FileUtils.mkdir_p(@temp_file_dir)

    FileUtils.cp(@raw_file.path, @temp_file_name)
    File.chmod(0666, @temp_file_name)

    return self
  end
  
  # 获取临时文件图片的宽高hash
  def temp_image_size
    temp_file = File.new(@temp_file_name)
    image = Magick::Image::read(temp_file).first

    return {:height=>image.rows, :width=>image.columns}
  end

  def temp_image_url
    @temp_file_url
  end

  # -------------------------------------
  
  def self.copper_logo(user, x1, y1, width, height)
    user_id_str = user.id.to_s
    temp_file_dir  = File.join(TEMP_FILE_BASE_DIR, user_id_str)
    temp_file_name = File.join(temp_file_dir, 'avatar_tmp')
    temp_file = File.new(temp_file_name)

    # 读取临时文件，裁切，转换格式
    img = Magick::Image::read(temp_file).first
    img.crop!(x1.to_i, y1.to_i, width.to_i, height.to_i, true)
    img.format = 'PNG'

    # 写第二个临时文件，裁切好的PNG文件
    coppered_file_name = File.join(temp_file_dir, 'avatar_tmp_coppered.png')
    img.write coppered_file_name

    # 赋值给user.logo (保存到云)
    coppered_file = File.new(coppered_file_name)
    user.update_attributes(:logo=>coppered_file)

    # 移除临时文件
    FileUtils.rm(temp_file_name)
    FileUtils.rm(coppered_file_name)
  end

end
