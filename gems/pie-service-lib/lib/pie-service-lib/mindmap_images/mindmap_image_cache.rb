class MindmapImageCache
  ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"
  attr_reader :mindmap
  def initialize(mindmap)
    @mindmap = mindmap
  end

  # 导图图片的硬盘缓存文件 的存放路径
  def img_path(size_param)
    File.join(ATTACHED_FILE_PATH_ROOT,"mindmap_cache_images",@mindmap.id.to_s,"#{size_param}.png")
  end

  # 根据导图内容生成 导图图片的硬盘缓存文件
  def refresh_cache_file(size_param)
    cache_path = self.img_path(size_param)
    begin
      tmp_image_path = MindmapToImage.new(@mindmap).export(size_param)
    rescue Exception => ex
      puts ex.backtrace*"\n"
      puts ex.message
      # 如果图片生成错误，那么 把一个导图生成错误的提示图片放到 导图图片的硬盘缓存文件
      tmp_image_path = "#{File.dirname(__FILE__)}/images/data_error.png"
    end
    dirname = File.dirname(cache_path)
    FileUtils.mkdir_p(dirname) if !File.exist?(dirname)
    FileUtils.rm(cache_path) if File.exist?(cache_path)
    FileUtils.cp(tmp_image_path,cache_path)
  end

  # 导图图片的硬盘缓存文件 是否有效 （存在并且没有过期）
  def cache_valid?(size_param)
    cache_path = self.img_path(size_param)
    return false if !File.exist?(cache_path)
    File.mtime(cache_path) > @mindmap.updated_at
  end

end
