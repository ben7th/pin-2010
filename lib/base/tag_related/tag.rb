class Tag < UserAuthAbstract
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

  def is_default?
    self.name == Tag::DEFAULT
  end

  def has_logo?
    !self.logo_updated_at.blank?
  end

  def full_name
    if self.namespace.blank?
      self.name
    else
      "#{self.namespace}:#{self.name}"
    end
  end

  def self.system_feature_ids
    Tag.get_tag_by_full_name("系统:功能更新").feeds.map{|f|f.id}
  rescue Exception => ex
    []
  end
  
  def self.get_tag(tag_name,namespace = nil)
    Tag.find_by_name_and_namespace(tag_name,namespace)
  end

  def self.get_tag_by_full_name(full_name)
    namespace = self.get_namespace_from_tag_full_name(full_name)
    name = self.get_name_from_tag_full_name(full_name)
    self.get_tag(name,namespace)
  end

  def self.get_namespace_from_tag_full_name(tag_full_name)
    arr = tag_full_name.split(":")
    return if arr.count == 1
    arr.first
  end

  def self.get_name_from_tag_full_name(tag_full_name)
    arr = tag_full_name.split(":")
    return arr.first if arr.count <= 1
    arr.shift
    arr*":"
  end

  def self.get_tag_names_by_string(tag_names_string,editor)
    return [] if tag_names_string.blank?
    tag_names = tag_names_string.split(/[，, ]+/).select{|name|!name.blank?}
    return tag_names if editor.is_admin_user?

    tag_names.map do |name|
      self.get_name_from_tag_full_name(name)
    end
  end

  def self.full_name_str(name,namespace=nil)
    return name if namespace.blank?
    return "#{namespace}:#{name}"
  end

  def users_map_of_created_feeds
    ab = ActiveRecord::Base.connection.select_all(%`
        select users.id,users.email,count(*) count from users
        inner join feeds on users.id = feeds.creator_id
        inner join feed_tags on feeds.id = feed_tags.feed_id
        where feed_tags.tag_id = #{self.id} and feeds.hidden = false
        group by users.id
        order by count desc
        limit 50
      `)
    ab.map do |item|
      user, count = User.find_by_id(item["id"]), item["count"]
      {user=>count}
    end
  end

  def users_map_of_memoed_feeds
        ab = ActiveRecord::Base.connection.select_all(%`
          select users.id,users.email,count(*) count from users
          inner join viewpoints on viewpoints.user_id = users.id
          inner join feed_tags on viewpoints.feed_id = feed_tags.feed_id
          inner join feeds on feeds.id = viewpoints.feed_id
          where feed_tags.tag_id = #{self.id} and feeds.hidden = false
          group by users.id
          order by count desc
          limit 50
      `)
    ab.map do |item|
      user, count = User.find_by_id(item["id"]), item["count"]
      {user=>count}
    end
  end

  include FeedTag::TagMethods
  include TagFav::TagMethods
  include TagRelatedFeedTagsMapProxy::TagMethods
end
