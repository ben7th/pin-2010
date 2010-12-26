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
  
  has_many :nodes
  has_one :visit_counter, :as=>:resource

  # name_scopes
  named_scope :publics,:conditions => ["private <> TRUE"]
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

  # 给平台发送分享
  def to_share
    return if self.private
    user = User.find(self.user_id)
    m_url = "#{URL_PREFIX}/mindmaps/#{self.id}"
    m_title = self.title
    content = "思维导图：#{m_title} #{m_url}"
    Share.create({"kind"=>"TALK", "content"=>content, "creator_id"=>user.id},:remote_user=>user)
  end

  def logo_url
    self&&self.logo ? "/mindmap/logo/#{self.send("logo_relative_path")}":"/images/logo/default_mindmap.png"
  end

  def logo_url_for_core
    logo_url
  end
  
  def root_default_title
    trans_xml_title(self.title)
  end
  
  # 将XML的Attribute t中的字符串转义符全部转义，这个方法的写法比较有技巧性
  # ruby里gsub的强大用法之一
  def trans_xml_title(title)
    title.gsub(/\\./){|m| eval '"'+m+'"'}
  end

  def save_on_default
    self.struct='<Nodes maxid="1"><N id="0" t="'+root_default_title+'" f="0"></N></Nodes>'
    self.save
  end
  
  def rebuild!
    MindmapStruct.rebuild(self)
  end

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
      mindmap.save_on_default
    end

    mindmap.new_record? ? false : mindmap
  end

  def toggle_private
    if self.private?
      return self.update_attributes(:private=>false)
    end
    self.update_attributes(:private=>true)
  end

  def refresh_local_id
    ms = MindmapStruct.new(self)
    ms.child_nodes.each do |cn|
      cn['id'] = randstr(8)
    end
    self.update_attribute(:struct,ms.struct)
  end

  module UserMethods
    def self.included(base)
      base.has_many :mindmaps
    end
  end

  include Snapshot::MindmapMethods
  include Comment::CommentableMethods
  include Cooperation::MindmapMethods
  
  include MindmapCloneMethods
  include MindmapApiMethods
  include MindmapExportAndImportMethods
  include MindmapRankMethods
  include MindmapSearchMethods
  include MindmapParseStructMethods
  include MindmapMd5Methods
  include ImageCache::MindmapMethods
  include MindmapNoteMethods
end
