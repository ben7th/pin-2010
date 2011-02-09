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

class Mindmap < ActiveRecord::Base

  belongs_to :user
  
  index :user_id
  index [:private,:user_id]
  index [:weight,:user_id]
  
  has_one :visit_counter, :as=>:resource

  # name_scopes
  named_scope :publics,:conditions => ["private <> TRUE or private is null"]
  named_scope :privacy,:conditions => ["private = TRUE"]
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
 
  @file_path = "#{ATTACHED_FILE_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{ATTACHED_FILE_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:s128=>'128x128>',:mini=>'32x32#'},
    :path => @file_path,
    :url => @file_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :mini

  # 根据传入的导图参数创建思维导图，在controller中被调用
  def self.create_by_params(user,params_mindmap)
    attrs_mindmap = params_mindmap
    import_file = attrs_mindmap[:import_file]
    attrs_mindmap.delete(:import_file)

    mindmap = Mindmap.new(attrs_mindmap)
    id = user ? user.id : 0
    mindmap.user_id = id

    if mindmap.valid? && import_file
      mindmap.import_from_file_and_save(import_file)
    else
      MindmapDocument.new(mindmap).init_default_struct
      mindmap.save
    end

    mindmap.new_record? ? false : mindmap
  end

  # 切换导图的 私有/公开 属性
  def toggle_private
    if self.private?
      return self.update_attributes(:private=>false)
    end
    self.update_attributes(:private=>true)
  end

  # 解析XML并转换为Hash对象
  # 取得思维导图文档解析对象实例
  def document
    MindmapDocument.new(self)
  end

  # 取得思维导图json
  def struct_json
    document.struct_hash.to_json
  end
  
  module UserMethods
    def self.included(base)
      base.has_many :mindmaps
    end

    # 已用空间大小
    def space_capacity
      path = File.join(MINDMAP_IMAGE_BASE_PATH,"users",self.id.to_s)
      `du -b #{path} | awk '{print $1}'`.to_i
    end

    # 用户空间是否满
    def space_is_full?
      space_capacity > 50 * 1024 * 1024
    end

    # 剩余空间
    def left_space
      50 * 1024 * 1024 - space_capacity
    end

    #　再加一个文件，用户空间的大小是否 满
    def space_is_full_after_add_file?(file)
      space_capacity + file.size >  50 * 1024 * 1024
    end
  end


  include Comment::CommentableMethods
  include Cooperation::MindmapMethods
  include Feed::MindmapMethods
  
  include MindmapCloneMethods
  include MindmapApiMethods
  include MindmapExportAndImportMethods
  include MindmapRankMethods
  include MindmapSearchMethods
  include MindmapRevisionMethods
  include MindmapNoteMethods
  include MindmapSnapshotMethods
  include MindmapImageMethods
  include MindmapRightsMethods
end
