class Mindmap < Mev6Abstract
  
  class SendStatus
    PUBLIC = "public"
    PRIVATE = "private"
  end
  SEND_STATUSES = [
    Mindmap::SendStatus::PUBLIC,
    Mindmap::SendStatus::PRIVATE
  ]
  
  MINDMAP_IMAGE_BASE_PATH = "/web/2010/mindmap_images"

  belongs_to :user
  
  has_one :visit_counter, :as=>:resource
  has_one :mindmap_file

  # name_scopes
  scope :publics,:conditions =>"mindmaps.send_status = '#{Mindmap::SendStatus::PUBLIC}'"
  scope :privacy,:conditions =>"mindmaps.send_status = '#{Mindmap::SendStatus::PRIVATE}'"

  scope :valueable,:conditions => ["weight > 0"]
  scope :of_user_id, lambda {|user_id|
    {:conditions=>['user_id = ?',user_id]}
  }
  scope :is_zero_weight?, lambda {|bool|
    if bool
      {:conditions=>'weight = 0'}
    else
      {:conditions=>'weight != 0'}
    end
  }

  scope :newest,:order=>'updated_at desc'
  
  
  # 校验部分
  validates_presence_of :title
 
  after_create :refresh_thumb_image
  def refresh_thumb_image
     MindmapImageCache.new(self).refresh_all_cache_file
  end

  def refresh_thumb_image_in_queue
    MindmapImageCacheQueueWorker.async_mindmap_image_cache(self)
    return true
  end

  def thumb_image_true_size
    _thumb_image_true_size(120)
  end

  def large_thumb_image_true_size
    _thumb_image_true_size(500)
  end

  def _thumb_image_true_size(size)
    if size == 120
      path = MindmapImageCache.new(self).thumb_120_img_path
    else
      path = MindmapImageCache.new(self).thumb_500_img_path
    end
    
    image = Magick::Image::read(File.new(path)).first
    {:height=>image.rows,:width=>image.columns}
  rescue Exception => ex
    {:height=>0,:width=>0}
  end
  
  # 根据传入的导图参数创建思维导图，在controller中被调用
  def self.new_by_params(user, params_mindmap)
    mindmap = Mindmap.new(params_mindmap)
    mindmap.user = user
    mindmap.document.init_default_struct
    return mindmap
  end
  
  def self.new_by_import(user, uploaded_file)
    importer = MindmapImporter.load(uploaded_file)
    
    mindmap = Mindmap.new({
      :user   => user,
      :title  => importer.title,
      :struct => importer.struct,
      :mindmap_file => MindmapFile.new(:file => uploaded_file)
    })

    return mindmap
  end
  
  # 切换导图的 私有/公开 属性
  def toggle_private
    if self.private?
      self.update_attribute(:send_status,Mindmap::SendStatus::PUBLIC)
    else
      self.update_attribute(:send_status,Mindmap::SendStatus::PRIVATE)
    end
  end

  # 解析XML并转换为Hash对象
  # 取得思维导图文档解析对象实例
  def document
    MindmapDocument.new(self)
  end
  
  # 取得思维导图json
  def struct_hash
    document.struct_hash
  end

  # 取得思维导图json
  def struct_json
    document.struct_hash.to_json
  end

  def private=(param)
    if param == "1" || param == 1 || !param
      self.send_status = Mindmap::SendStatus::PRIVATE
    else
      self.send_status = Mindmap::SendStatus::PUBLIC
    end
  end
  
  def public?
    self.send_status == Mindmap::SendStatus::PUBLIC
  end
  
  def private?
    self.send_status == Mindmap::SendStatus::PRIVATE
  end

  def low_value?
    self.document.nodes.length <= 3
  end

  def mindmap_file_url
    mf = self.mindmap_file
    unless mf.blank?
      mf.file.url
    end
  end

  def mindmap_file_type
    mf = self.mindmap_file
    unless mf.blank?
      File.extname(mf.file_file_name)[1..-1]
    end
  end

  def thumb_image_url(size_param)
    id        = self.id
    asset_id  = (id / 1000).to_s
    cache_num = self.updated_at.to_i

    src = pin_url_for("dtimg","/asset/#{asset_id}/#{id}.#{size_param}.png?#{cache_num}")

    return src.gsub 'dtimg0',"dtimg#{id % 10}"
  end

  module UserMethods
    def self.included(base)
      base.has_many :mindmaps,:order=>"mindmaps.updated_at desc"
    end

    def mindmaps_count
      Mindmap.count(:all, :conditions => "user_id = #{self.id}")
    end

    # 已用空间大小
    def space_capacity
      self.image_attachments.map{|ia|ia.image.size}.sum
    end
  end




  include MindmapSearchMethods
  include MindmapRevisionMethods
  include MindmapNoteMethods
  include MindmapRightsMethods

  include MindmapFav::MindmapMethods
  include HistoryRecord::MindmapMethods
end
