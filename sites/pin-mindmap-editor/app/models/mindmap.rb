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
require "rexml/document"
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

# 搜索方面的
  define_index do
    indexes :content
    indexes :title

    has :user_id, :created_at,:updated_at

    where "private <> TRUE"
  end

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
  
  def update_or_create_note(local_id,note)
    if note!=''&&note!='<br>'
      node=nodes.find_or_create_by_local_id(local_id)
      node.note=note
      node.save
    else
      node=nodes.find_by_local_id(local_id)
      node.destroy unless node.blank?
    end
  end
  
  # 进行修改操作
  def do_operation(oper)
    old_struct = self.struct.clone;
    doc = REXML::Document.new(self.struct)
    case oper['op']
    when 'do_insert' then
      parent = doc.elements["//N[@id='#{oper['params']['parent']}']"]
      node = REXML::Document.new("<N id='#{oper['node']}' t='NewSubNode' f='0'/>")
      idx = oper['params']['index']
      new_maxid = doc.elements["Nodes"].attributes['maxid'].to_i+1
      doc.elements["Nodes"].attributes['maxid'] = new_maxid.to_s
      if idx==0 then
        parent << node
      else
        prev = parent.elements[idx]
        parent.insert_after prev,node
      end
    when 'do_delete' then
      node = doc.elements["//N[@id='#{oper['node']}']"]
      node.parent.delete node
    when 'do_title' then
      node = doc.elements["//N[@id='#{oper['node']}']"]
      node.attributes['t']=oper['params']['title']
    when 'do_toggle' then
      node = doc.elements["//N[@id='#{oper['node']}']"]
      node.attributes['f']=oper['params']['fold'].to_s
    when 'do_image' then
      node = doc.elements["//N[@id='#{oper['node']}']"]
      node.attributes['i']=oper['params']['url']
      node.attributes['iw']=oper['params']['width'].to_s
      node.attributes['ih']=oper['params']['height'].to_s
    when 'do_move' then
      node = doc.elements["//N[@id='#{oper['node']}']"]
      node.parent.delete node
      node.attributes['pr']=oper['params']['putright'].to_s
      new_parent = doc.elements["//N[@id='#{oper['params']['parent']}']"]
      idx = oper['params']['index']
      if new_parent.elements.size>0 && idx<new_parent.elements.size
        next_node = new_parent.elements[idx+1]
        new_parent.insert_before next_node,node
      else
        new_parent << node
      end
    when 'do_note' then
      self.update_or_create_note(oper['node'],oper['params']['note'])
    end
    self.struct = doc.to_s
    if self.struct!=old_struct
      self.save!
    end
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

  module UserMethods
    def self.included(base)
      base.has_many :mindmaps
    end
  end

  include Snapshot::MindmapMethods
  include Comment::CommentableMethods
  
  include MindmapCloneMethods
  include MindmapApiMethods
  include MindmapExportAndImportMethods
  include MindmapRankMethods
  include MindmapSearchMethods
  include MindmapParseStructMethods
  include MindmapMd5Methods
end
