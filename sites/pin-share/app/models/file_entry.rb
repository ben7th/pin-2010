# == Schema Information
# Schema version: 20091223090135
#
# Table name: file_entries
#
#  id                   :integer(4)      not null, primary key
#  title                :string(255)     
#  content_file_name    :string(255)     
#  content_content_type :string(255)     
#  content_file_size    :integer(4)      
#  created_at           :datetime        
#  updated_at           :datetime        
#

class FileEntry < ActiveRecord::Base
  include Entry::ResourceMethods

  @file_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @file_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :content,
    :path => @file_path,
    :url => @file_url,
    :styles => {:thumb => '300x300>',:s120=>'120x120>',:mini => '64x64>'}

  validates_attachment_presence :content,:message=>'請上傳文件'

  # 文件的名称（原始名称）
  def file_name
    title
  end

  # 根据文件的后缀名判断类型
  # 例如 1.mp3 的类型是 MP3
  def file_type
    name = self.content_file_name
    name.split(".").last.upcase
  end

  require 'digest/md5'
  def file_md5
    Digest::MD5.hexdigest(File.read(self.content.path))
  rescue
    ""
  end

  # 判断该文件资源是否是图像文件
  def is_image?
    case self.file_type
    when "BMP" then true
    when "JPG" then true
    when "PNG" then true
    when "JPEG" then true
    when "GIF" then true
    else false
    end
  end

  # 判断该文件资源是否是声音文件
  def is_audio?
    case self.file_type
    when "MP3" then true
    when "WMA" then true
    else false
    end
  end

  # 判断该文件资源是否是视频文件
  def is_video?
    case self.file_type
    when "FLV" then true
    else false
    end
  end

  def file_view_type
    return 'image' if self.is_image?
    return 'file'
  end

  # 返回量化的大小
  def file_size_with_a_unit
    FileEntry.file_size_with_a_unit(self.content_file_size)
  end

  def self.file_size_with_a_unit(size)
    case size
    when 0..1000 then return size.to_s << "B"
    when 1000..1000000 then return ((size)/(1024.0)).round(1).to_s << "K"
    when 1000000..10000000000000000 then return ((size)/(1024.0*1024.0)).round(1).to_s << "M"
    end
  end

  DETAILS=["Min","Max"]
  MIN = "Min"
  MAX = "Max"

  def change_detail
    if self.detail == MAX
      self.update_attributes(:detail=>MIN)
      return
    end
    self.update_attributes(:detail=>MAX)
  end

  def url
    content.url
  end

  def to_xml(options={},&block)
    super(options.merge({:only=>[:id,:created_at],:methods=>:url}),&block)
  end

  require 'zip/zipfilesystem'
  require 'zip/zip'
  # 导出host中的所有附件到一个zip文件中
  def to_zip
    zip_path = Dir::tmpdir + '/'+ UUID.random_create.to_s + ".zip"
    zip = Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE)
    zip.add(self.title.utf8_to_gbk,self.content.path)
    zip.close
    return zip_path
  end

  def self.search(keyword,user)
    FileEntry.find(:all,:conditions=>[' title like ? ',"%#{keyword}%"]).map{|file_entry|file_entry.entry if file_entry.entry&&file_entry.entry.user == user&&file_entry.entry.deleted_at.blank?}.compact
  end

  include Share::ShareableMethods
end
