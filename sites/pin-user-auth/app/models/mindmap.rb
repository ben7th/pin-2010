class Mindmap < Mev6Abstract
  belongs_to :user

  index :user_id
  index [:private,:user_id]
  index [:weight,:user_id]

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

  @file_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:s128=>'128x128>',:mini=>'32x32#'},
    :path => @file_path,
    :url => @file_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :mini

  def self.create_by_title(user,title)
    mindmap = Mindmap.new(:title=>title,:user=>user)
    if mindmap.valid?
      MindmapDocument.new(mindmap).init_default_struct
      mindmap.save
      return mindmap
    end
    false
  end

  def self.import(user,file_name,file)
    self.verify_active_connections!
    name_splits = file_name.split(".")
    type = name_splits.pop
    title = name_splits*""

    mindmap = Mindmap.new
    mindmap.user_id = user.id
    mindmap.title = title

    case type
    when 'mmap' then MindmanagerParser.import(mindmap,file)
    when 'mm' then FreemindParser.import(mindmap,file)
    when 'xmind' then XmindParser.import(mindmap,file)
    when 'imm' then ImindmapParser.import(mindmap,file)
    else
      raise "错误的导图格式"
    end
    mindmap
  end

  def rank_value
    rank
  end

  # 解析XML并转换为Hash对象
  # 取得思维导图文档解析对象实例
  def document
    MindmapDocument.new(self)
  end

  def prev(current_user)
    if current_user == self.user
      mindmap_ids = self.user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    else
      mindmap_ids = self.user.mindmaps.publics.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    end
    index = mindmap_ids.index(self.id)
    return if index == 0
    Mindmap.find(mindmap_ids[index-1])
  end
  
  def next(current_user)
    if current_user == self.user
      mindmap_ids = self.user.mindmaps.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    else
      mindmap_ids = self.user.mindmaps.publics.sort{|a,b|b.updated_at <=> a.updated_at}.map{|mindmap|mindmap.id}
    end
    index = mindmap_ids.index(self.id)
    return if index == (mindmap_ids.count-1)
    Mindmap.find(mindmap_ids[index+1])
  end
  
  module UserMethods
    def mindmaps_count
      Mindmap.count(:all, :conditions => "user_id = #{self.id}")
    end
  end

  include Cooperation::MindmapMethods
  include Feed::MindmapMethods
  
  include MindmapCloneMethods
  include MindmapExportAndImportMethods
  include MindmapRankMethods
  include MindmapSearchMethods
  include MindmapRevisionMethods
  include MindmapNoteMethods
  include MindmapSnapshotMethods
  include MindmapImageMethods
  include MindmapRightsMethods
end
