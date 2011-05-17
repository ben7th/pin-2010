class Tag < UserAuthAbstract
  version 201105131
  DEFAULT = "没有关键词"

  validates_format_of :name,:with=>/^[A-Za-z0-9一-龥]+$/

  # logo
  @logo_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {:raw=>'500x500>',:medium=>"96x96#",:normal=>"48x48#",:tiny=>'32x32#',:mini=>'24x24#' },
    :path => @logo_path,
    :url => @logo_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :normal

  def has_logo?
    !self.logo_updated_at.blank?
  end

  def self.has_logo?(tag_name)
    tag = Tag.find_by_name(tag_name)
    return false if tag.blank?
    tag.has_logo?
  end

  include FeedTag::TagMethods
end
