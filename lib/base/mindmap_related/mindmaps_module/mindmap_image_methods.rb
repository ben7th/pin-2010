module MindmapImageMethods

  class UploadError < StandardError;end
  class DeleteUploadedImageError < StandardError;end
  class SpaceNotEnoughError < StandardError;end
   
  # 本地文件上传到版本库
  def upload_file_to_repo(file)
    # 文件名
    name_suffix = file_name_suffix_from_path(file.original_filename)
    file_name = "#{randstr(8)}.#{name_suffix}"
    # 把文件提交到版本库
    # 如果空间没有达到最大值，可以增加文件到版本库
    if(!self.user.space_is_full_after_add_file?(file))
      add_file_to_repo(file_name,file.path)
    else
      raise SpaceNotEnoughError,"用户空间不足"
    end
    return file_name
  rescue Exception => ex
    raise UploadError,ex.message
  end

  def upload_file_thumb_absolute_path(file_name)
    File.join(self.thumb_images_base_path,file_name)
  end

  def upload_file_absolute_path(file_name)
    File.join(self.images_base_path,file_name)
  end

  def images
    file_names = Dir.entries(self.images_base_path)
    file_names.delete(".")
    file_names.delete("..")
    file_names.delete("thumb")
    file_names.sort do |name_1,name_2|
      File.mtime(File.join(self.images_base_path,name_2)) <=> File.mtime(File.join(self.images_base_path,name_1))
    end
  rescue
    []
  end

  def images_base_path
    File.join(Mindmap::MINDMAP_IMAGE_BASE_PATH,"users",self.user.id.to_s)
  end

  def thumb_images_base_path
    File.join(Mindmap::MINDMAP_IMAGE_BASE_PATH,"users",self.user.id.to_s,"thumb")
  end

  # 删除 已经上传的 文件
  def delete_file(file_name)
    file_path = File.join(images_base_path,file_name)
    FileUtils.rm(file_path)
    return true
  rescue Exception=>ex
    raise DeleteUploadedImageError,ex.message
    return false
  end

  private
  def file_name_suffix_from_url(url)
    fname = URI.parse(url).path.split("/").last
    file_name_suffix_from_name(fname)
  end

  def add_file_to_repo(file_name,tmp_file_path)
    # 增加一个文件到版本库
    FileUtils.mkdir_p(self.images_base_path) if !File.exist?(self.images_base_path)
    absolute_file_path = upload_file_absolute_path(file_name)
    FileUtils.copy_file(tmp_file_path,absolute_file_path)
    # 生成缩略图
    FileUtils.mkdir_p(self.thumb_images_base_path) if !File.exist?(self.thumb_images_base_path)
    thumb_path = ImgResize.new(absolute_file_path).dump_max_of(90,60)
    thumb_absolute_file_path = upload_file_thumb_absolute_path(file_name)
    FileUtils.copy_file(thumb_path,thumb_absolute_file_path)
    mup_ap tmp_file_path
    mup_ap absolute_file_path
    mup_ap thumb_absolute_file_path
    mup_ap thumb_path
    FileUtils.rm_r(thumb_path)
  end

  def file_name_suffix_from_path(file_path)
    fname = file_path.split("/").last
    file_name_suffix_from_name(fname)
  end

  def file_name_suffix_from_name(file_name)
    name_splits = file_name.split(".")
    name_suffix = name_splits.last
    name_suffix = "png" if name_splits.count == 1
    name_suffix
  end
end