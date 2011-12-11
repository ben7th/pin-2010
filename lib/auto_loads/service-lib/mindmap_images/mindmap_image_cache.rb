class MindmapImageCache
  if RAILS_ENV == "development"
    ATTACHED_FILE_PATH_ROOT = "/web1/2010/cache_images"
  else
    ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"
  end

  THUMB_500 = "500x500"
  THUMB_120 = "120x120"
  ZOOM_1 = "1"

  attr_reader :mindmap
  def initialize(mindmap)
    @mindmap = mindmap
  end

  def refresh_all_cache_file
    refresh_cache_file
  end

  def thumb_500_img_path
    img_path(THUMB_500)
  end

  def thumb_120_img_path
    img_path(THUMB_120)
  end

  # 导图图片的硬盘缓存文件 的存放路径
  # 12月11日 由于环境迁移 EXT3 文件系统单一目录下子目录数量有限制，因此
  # 导图ID > 42033 （产品环境超限的导图id）
  # 时，分多个文件夹
  def img_path(size_param)
    id = @mindmap.id

    if id <= 42033
      return File.join(ATTACHED_FILE_PATH_ROOT, "mindmap_cache_images", id.to_s, "#{size_param}.png")
    else
      asset_path = (id / 10000).to_s
      return File.join(ATTACHED_FILE_PATH_ROOT, "mindmap_cache_images", asset_path, id.to_s, "#{size_param}.png")
    end
  end

  def export(zoom = 1)
    begin
      return MindmapToImage.new(@mindmap).export(zoom)
    rescue Exception => ex
      puts ex.backtrace*"\n"
      puts ex.message
      # 如果图片生成错误，那么 把一个导图生成错误的提示图片放到 导图图片的硬盘缓存文件
      return "#{File.dirname(__FILE__)}/images/data_error.png"
    end
  end

  # 根据导图内容生成 导图图片的硬盘缓存文件
  def refresh_cache_file
    s500_cache_path = self.img_path(THUMB_500)
    s120_cache_path = self.img_path(THUMB_120)

    use_error_image = false
    
    begin
      thumb_path_info = MindmapToImage.new(@mindmap).create_thumb
      s500_path = thumb_path_info[:s500]
      s120_path = thumb_path_info[:s120]
    rescue Exception => ex
      puts ex.backtrace*"\n"
      puts ex.message
      # 如果图片生成错误，那么 把一个导图生成错误的提示图片放到 导图图片的硬盘缓存文件
      error_image_path = "#{File.dirname(__FILE__)}/images/data_error.png"
      use_error_image = true
      s500_path = error_image_path
      s120_path = error_image_path
    end

    # 500
    s500_dirname = File.dirname(s500_cache_path)
    FileUtils.mkdir_p(s500_dirname) if !File.exist?(s500_dirname)
    FileUtils.rm(s500_cache_path) if File.exist?(s500_cache_path)
    FileUtils.cp(s500_path,s500_cache_path)
    FileUtils.rm(s500_path) if !use_error_image

    # 120
    s120_dirname = File.dirname(s120_cache_path)
    FileUtils.mkdir_p(s120_dirname) if !File.exist?(s120_dirname)
    FileUtils.rm(s120_cache_path) if File.exist?(s120_cache_path)
    FileUtils.cp(s120_path,s120_cache_path)
    FileUtils.rm(s120_path) if !use_error_image
  end


  def create_zoom_1_cache_file
    save_path = self.img_path(ZOOM_1)

    file_path = ""
    use_error_image = false
    begin
      file_path = MindmapToImage.new(@mindmap).export(1)
    rescue Exception => ex
      use_error_image = true
      file_path = "#{File.dirname(__FILE__)}/images/data_error.png"
    end

    dirname = File.dirname(save_path)
    FileUtils.mkdir_p(dirname) if !File.exist?(dirname)
    FileUtils.rm(save_path) if File.exist?(save_path)
    FileUtils.cp(file_path,save_path)
    FileUtils.rm(file_path) if !use_error_image
    return save_path
  end

end
