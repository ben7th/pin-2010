class ImageCache
  ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"
  def self.img_path(size_param,mindmap)
    File.join(ATTACHED_FILE_PATH_ROOT,"cache_images",mindmap.id.to_s,"#{size_param}.png")
  end

  module MindmapMethods
    def get_img_path_by(size_param)
      cache_path = ImageCache.img_path(size_param,self)
      if _cache_expire(size_param)
        # 更新附件
        image_path = MindmapToImage.new(self).export(size_param)
        dirname = File.dirname(cache_path)
        FileUtils.mkdir_p(dirname) if !File.exist?(dirname)
        FileUtils.rm(cache_path) if File.exist?(cache_path)
        FileUtils.cp(image_path,cache_path)
      end
      return cache_path
    end

    private
    def _cache_expire(size_param)
      cache_path = ImageCache.img_path(size_param,self)
      return true if !File.exist?(cache_path)
      mindmap_last_updated_at = File.mtime(cache_path)
      mindmap_last_updated_at != self.updated_at
    end
  end
end
