class ImageCache < ActiveRecord::Base

  belongs_to :mindmap
  # cache_money
  #index [:mindmap_id, :size_param]
  ATTACHED_FILE_URL_ROOT = "http://img.2010.mindpin.com/"
  ATTACHED_FILE_PATH_ROOT = "/web/2010/images/"
  @file_path = "#{ATTACHED_FILE_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{ATTACHED_FILE_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :img,
    :path => @file_path,
    :url => @file_url
  
  def validate_on_create
    if ImageCache.find_by_mindmap_id_and_size_param(self.mindmap_id,self.size_param)
      errors.add_to_base("已经存在id为#{self.mindmap_id}size_param为#{self.size_param}的记录")
    end
  end

  module MindmapMethods
    def get_img_path_by(size_param)
      if self.private
        return "#{RAILS_ROOT}/public/images/private_map.png"
      end
      cache = ImageCache.find_or_create_by_mindmap_id_and_size_param(self.id,size_param)
      if cache.mindmap_last_updated_at != self.updated_at
        # 更新附件
        image_path = MindmapToImage.new(self).export(size_param)
        image = File.open(image_path)
        cache.img = image
        image.close
        
        # 更新对应mindmap的最新更新时间
        cache.mindmap_last_updated_at = self.updated_at
        cache.save
      end
      return cache.img.path
    end
  end
end