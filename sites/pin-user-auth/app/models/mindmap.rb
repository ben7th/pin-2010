class Mindmap < ActiveRecord::Base
  belongs_to :user
  # set_readonly(true)
  build_database_connection(CoreService::MINDMAP_EDITOR)

  index :user_id

  # 校验部分
  validates_presence_of :title

  @file_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
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

  def self.import(user,file_name,file)
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
