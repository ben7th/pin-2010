# == Schema Information
# Schema version: 20091223090135
#
# Table name: entries
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      
#  resource_id   :integer(4)      
#  resource_type :string(255)     
#  created_at    :datetime        
#  updated_at    :datetime        
#

class Entry < ActiveRecord::Base
  include Pacecar
  is_paranoid

  belongs_to :resource,:polymorphic => true
  belongs_to :host,:polymorphic=>true
  belongs_to :user
  belongs_to :creator,:foreign_key => 'user_id',:class_name => 'User'


  validates_presence_of :user_id  

  named_scope :file_entries,:conditions=>{:resource_type=>"FileEntry"}

  named_scope :order_by_rand,:order=>"rand()"

  # TODO 这里目前还是硬编码，稍后应该改成根据类名自动定义，去掉case语句
  named_scope :type_of, lambda{ |klass_or_type|
    type = klass_or_type.to_s
    case type
    when 'FileEntry','file','file_entry'
      {:conditions=>{:resource_type=>"FileEntry"}}
    when 'Bookmark','bookmark','book_mark','BookmarkEntry','bookmark_entry'
      {:conditions=>{:resource_type=>"BookmarkEntry"}}
    when 'SubscriptionEntry','subscription','subscription_entry'
      {:conditions=>{:resource_type=>"SubscriptionEntry"}}
    end
  }
  
  # select id,resource_id,resource_type
  # from entries
  # where resource_type
  # in ( 'FileEntry',"BookmarkEntry")
  named_scope :types_of,lambda{|type_arr|
    str_arr = type_arr.map{|type|Entry.type_to_class_str(type)}.compact
    # ['FileEntry',"BookmarkEntry"] => "('FileEntry',"BookmarkEntry")"
    {:conditions=>"resource_type in #{str_arr.to_brackets_str}"}
  }

  def self.type_to_class_str(type)
    case type.to_s
    when 'FileEntry','file','file_entry'
      return 'FileEntry'
    when 'BookmarkEntry','bookmark','bookmark_entry'
      return 'BookmarkEntry'
    end
  end

  named_scope :user_of,lambda{ |user|
    {:conditions=>{:user_id=>user.id}}
  }

  named_scope :used,lambda { |used|
    case used
    when true
      {:conditions=>['host_id is not null and host_type is not null']}
    when false
      {:conditions=>['host_id is null or host_type is null']}
    end
  }

  named_scope :order, lambda { |order|
    case order
    when "created_at_asc"
      { :order=>"created_at asc"}
    when 'created_at_desc'
      { :order=>"created_at desc"}
    when 'size_asc'
      { :order => "file_entries.content_file_size asc",:joins=>"left join file_entries on file_entries.id = entries.resource_id and entries.resource_type = 'FileEntry'"}
    when 'size_desc'
      { :order => "file_entries.content_file_size desc",:joins=>"left join file_entries on file_entries.id = entries.resource_id and entries.resource_type = 'FileEntry'"}
    end
  }

  named_scope :bookmark_url_is, lambda { |url|
    { :joins=>"right join bookmark_entries on entries.resource_type = 'BookmarkEntry' and entries.resource_id = bookmark_entries.id",
      :conditions=>['bookmark_entries.url = ?',url]
    }
  }

  # 定义分页时，每页的数目
  def self.per_page
    10
  end

  def resource_meta=(hash)
    return self.resource.update_attributes!(hash[:data]) if !self.new_record?
    self.resource = case hash[:type]
    when 'FileEntry'
      FileEntry.new(hash[:data])
    when "BookmarkEntry"
      BookmarkEntry.new(hash[:data])
    end
  end

  def validate_on_create
    unless self.resource.valid?
      errors.add_to_base("内容不能为空")
    end
  end

  # 为随机阅读产生一条随机entry的id
  # FileEntry(除图片外)舍去
  # 长度小于50的舍去
  def self.get_random_readable_id_for_reads(user)
    entry = order_by_rand.limited(1).first
    # 如果是不喜欢的
    return get_random_readable_id_for_reads if entry.feel_of(user) == Feeling::BAD
    resource = entry.resource
    case resource
    when FileEntry
      # 如果不是图片
      return get_random_readable_id_for_reads(user) if !resource.is_image?
    end
    return entry.id
  end

  module ResourceMethods
    def self.included(base)
      base.has_one :entry,:as => :resource
      base.after_update :update_entry_update_time
    end

    def update_entry_update_time
      self.entry.update_attributes!(:updated_at=>Time.now)
    end

    # 这个entry被什么东西引用过
    def used_for
      return "" if self.entry.host_type.blank? && self.entry.host_id.blank?
      begin
        self.entry.host
      rescue Exception => ex
        "原对象已删除"
      end
    end

  end

  # 查找某某用户的资源数
  def self.count_by_user(user)
    return Entry.count(:conditions => {:user_id => user.id})
  end

  # 用友好的格式返回 该资源的类型
  def type_str
    case self.resource_type
    when "FileEntry" then "文件资源"
    end
  end

  # hash=>{:entry=>entry,:user=>user}
  def send_mail_to(user)
    Mailer.deliver_send_entry(self,user,"normal")
  end

  # hash=>{:entry=>entry,:user=>user}
  def send_zip_mail_to(user)
    Mailer.deliver_send_entry(self,user,"zip")
  end

  module UserMethods
    def self.included(base)
      base.has_many :entries,:foreign_key=>"user_id"
    end
  end

  module HostMethods
    def self.included(base)
      base.has_many :entries,:class_name=>"Entry",:as=>:host
    end
  end

  include Share::ShareableMethods
  include Feeling::FeelableMethods
  include Using::EntryMethods
end