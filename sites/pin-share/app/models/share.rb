class Share < ActiveRecord::Base


  belongs_to :entry
  belongs_to :shareable,:polymorphic => true
  belongs_to :creator,:class_name=>"User",:foreign_key=>"creator_id"
  belongs_to :last_forward,:class_name=>"Share",:foreign_key=>"last_forward_id"

  validates_presence_of :creator

  TALK = "TALK"
  SHARE = "SHARE"

  def validate
    if self.kind==Share::TALK && self.shareable.blank? && self.content.blank?
      errors.add("content", "不能为空")
    end
  end

  named_scope :contacts_shares_of, lambda{ |user|
    {
      :joins=>"inner join contactings on shares.creator_id = contactings.contact_id",
      :conditions=>"contactings.host_id = #{user.id}",
      :order=>"shares.created_at desc"
    }
  }

  before_create :set_content
  def set_content
    self.content = "分享" if self.content.blank?
    # 将这里面的url全部全部创建short_url
    # 同时把content中的url替换成short_url
    pick_up_urls_from_content.each do |url|
      next if ShortUrl.is_in_this_site?(url) # 本站站点不进行转换
      code_url = ShortUrl.get_short_url(url)
      self.content.gsub!(url,code_url)
    end
  end

  after_save :add_using_to_entry

  # 如果当前链接在 当前用户的 BookmarkEntry 中存在，
  # 则增加一条 bookmark使用记录
  # 如果当前链接在 当前用户的 BookmarkEntry 中不存在，不做额外处理
  # 都是对bookmark_entry所在的entry操作
  def add_using_to_entry
    check_url_in_bookmarks.each do |entry|
      Using.find_or_create_by_share_id_and_entry_id(self.id,entry.id)
    end
  end

  # 从content中找到所有的url 并返回url数组
  def pick_up_urls_from_content
    self.content.gsub(%r(( https?:// )[^\s<]+)x).to_a.map do |url|
      url.sub(/[\"\']$/, '')
    end
  end

  # 查找这个url所在的bookmark_entry的entry
  def check_url_in_bookmarks
    pick_up_urls_from_content.map do |url|
      url = ShortUrl.original_url(url)
      entries = self.creator.entries.bookmark_url_is(url)
      if !entries.blank?
        entries[0]
      end
    end.compact.uniq
  end

  def Share.new_by_params(params_share,shareable,entry_id)
    content = params_share.blank? ? "" : params_share[:content]
    # 如果传进来的是entry不是空，则保存这个share的附件
    # 闲聊
    if shareable.blank?
      return Share.new(:content=>content,:kind=>Share::TALK,:entry_id=>entry_id)
    end
    # 分享
    if shareable.class != Share
      return shareable.shares.new(:content=>content,:kind=>Share::SHARE)
    end
    # 转发分享或转发闲聊
    if shareable.class == Share
      kind = shareable.kind
      #      last_forward = shareable
      s = shareable.shareable
      if s
        return s.shares.new(:last_forward=>shareable,:content=>content,:kind=>kind)
      else
        return shareable.shares.new(:content=>content,:kind=>kind)
      end
    end
  end

  module ShareableMethods
    def self.included(base)
      base.has_many :shares,:as=>:shareable
    end

    # 检测这个entry是否已经被这个user分享
    # 如果已经分享返回true,如果没有返回false
    def shared_by?(user)
      share = Share.find_by_shareable_id_and_shareable_type_and_creator_id(self.id,self.class.to_s,user.id)
      return share.blank? ? false : true
    end

    # 被分享的次数
    def shared_count
      size = Share.find_all_by_shareable_id_and_shareable_type(self.id,self.class.to_s).size
      if self.class != Share
        return size
      end
      size_2 = Share.find_all_by_last_forward_id(self.id).size
      return size + size_2
    end

    # 分享内容中的思维导图链接
    # 返回 {"缩略图链接"=>原图链接}
#    def mindmap_urls
#      re = %r{#{THIS_SITE}app/#{App::MINDMAP_EDITOR}/mindmaps/([^\"\'\s]*)}
#      urls_hash = {}
#      self.content.gsub(re) do
#        key = "#{IMAGE_CACHE_SITE}images/#{$1}.png?size_param=120x90"
#        urls_hash[key] = "#{$&}.png"
#      end
#      urls_hash
#    end
  end

  # 分享内容中的 bugs 链接
  # 返回 {"内容"=>原链接}
  def bugs_urls
    re = %r{#{THIS_SITE}bugs/([^\"\'\s]*)}
    urls_hash = {}
    self.content.gsub(re) do
      id = $1
      bug = Bug.find_by_id(id)
      if bug
        key = bug.content
        urls_hash[key] = "#{THIS_SITE}bugs/#{id}"
      end
    end
    urls_hash
  end

  module UserMethods
    def self.included(base)
      base.has_many :shares,:foreign_key=>"creator_id",:order=>"created_at desc"
    end

    # 我的分享，以及我设置可见的好友的分享
    def my_and_contacting_shares
      show_share_users = self.contactings.find(:all,:conditions=>{:show_share=>true}).map{|c|c.contact}
      show_share_users_ids = [show_share_users,self].flatten
      Share.find(:all,:conditions=>['creator_id in (?) ',show_share_users_ids],:order=>"created_at desc")
    end
  end

  include Share::ShareableMethods
  include Feeling::FeelableMethods
  include Using::ShareMethods
end
