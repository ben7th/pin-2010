class MindmapImageCache
  if RAILS_ENV == "development"
    ATTACHED_FILE_PATH_ROOT = "/web1/2010/cache_images"
  else
    ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"
  end

  THUMB_500 = "500x500"
  THUMB_120 = "120x120"

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
  def img_path(size_param)
    File.join(ATTACHED_FILE_PATH_ROOT,"mindmap_cache_images",@mindmap.id.to_s,"#{size_param}.png")
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

end
