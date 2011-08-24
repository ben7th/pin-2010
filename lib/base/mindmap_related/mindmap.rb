# == Schema Information
# Schema version: 20081118030512
#
# Table name: mindmaps
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)      not null
#  title       :string(255)     default(""), not null
#  description :string(255)     
#  struct      :text            
#  logo        :string(255)     
#  score       :float           
#  private     :boolean(1)      
#  created_at  :datetime        
#  updated_at  :datetime        
#
require 'uuidtools'

class Mindmap < Mev6Abstract
  class SendStatus
    PUBLIC = "public"
    PRIVATE = "private"
  end
  SEND_STATUSES = [
    Mindmap::SendStatus::PUBLIC,
    Mindmap::SendStatus::PRIVATE
  ]
  MINDMAP_IMAGE_BASE_PATH = CoreService.find_setting_by_project_name(CoreService::MEV6)["mindmap_image_base_path"]
  belongs_to :user
  
  index :user_id
  index [:weight,:user_id]
  
  has_one :visit_counter, :as=>:resource

  # name_scopes
  named_scope :publics,:conditions =>"mindmaps.send_status = '#{Mindmap::SendStatus::PUBLIC}'"
  named_scope :privacy,:conditions =>"mindmaps.send_status = '#{Mindmap::SendStatus::PRIVATE}'"

  named_scope :valueable,:conditions => ["weight > 0"]
  named_scope :of_user_id, lambda {|user_id|
    {:conditions=>['user_id = ?',user_id]}
  }
  named_scope :is_zero_weight?, lambda {|bool|
    if bool
      {:conditions=>'weight = 0'}
    else
      {:conditions=>'weight != 0'}
    end
  }

  named_scope :newest,:order=>'updated_at desc'
  
  
  # 校验部分
  validates_presence_of :title
 
  @file_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:s128=>'128x128>',:mini=>'32x32#'},
    :path => @file_path,
    :url => @file_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :mini

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

  def self.import(user,attrs,struct)
    mindmap = Mindmap.new(attrs)
    mindmap.user = user
    mindmap.struct = struct
    if mindmap.valid?
      mindmap.save
    end
    mindmap
  end

  # 根据传入的导图参数创建思维导图，在controller中被调用
  def self.create_by_params(user,params_mindmap)
    mindmap = Mindmap.new(params_mindmap)
    mindmap.user = user
    if mindmap.valid?
      MindmapDocument.new(mindmap).init_default_struct
      mindmap.save
      return mindmap
    end
    mindmap
  end

  def rank_value
    rank
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

  def prev(current_user)
    user = self.user
    return nil if user.blank?

    if current_user == user
      mindmap_ids = user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    else
      mindmap_ids = user.out_mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    end
    index = mindmap_ids.index(self.id)
    return if index == 0 || index.blank?
    Mindmap.find(mindmap_ids[index-1])
  end

  def next(current_user)
    user = self.user
    return nil if user.blank?

    if current_user == user
      mindmap_ids = user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    else
      mindmap_ids = user.out_mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    end
    index = mindmap_ids.index(self.id)
    return if index == (mindmap_ids.count-1) || index.blank?
    Mindmap.find(mindmap_ids[index+1])
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

    def mindmaps_chart_arr
      mindmaps = self.out_mindmaps
      MindmapsRankTendencyChart.new(mindmaps).values
    end
  end


  include MindmapCloneMethods
  include MindmapExportAndImportMethods
  include MindmapRankMethods
  include MindmapSearchMethods
  include MindmapRevisionMethods
  include MindmapNoteMethods
  include MindmapSnapshotMethods
  include MindmapImageMethods
  include MindmapRightsMethods

  include MindmapCooperationMethods
  include MindmapComment::MindmapMethods
  include MindmapFav::MindmapMethods

  include FeedMindmap::MindmapMethods

  include HistoryRecord::MindmapMethods
end
