require 'zip/zipfilesystem'
require 'zip/zip'
require 'uuidtools'

class Note < ActiveRecord::Base
  belongs_to :user
  named_scope :publics,:conditions => ["private <> TRUE"]
  named_scope :privacy,:conditions => ["private = TRUE"]
  has_many :comments

  named_scope :star_of_user, lambda{ |user|
    {:joins=>" inner join stars on notes.id=stars.note_id",
      :conditions=>"stars.email = '#{user.email}'"}
  }

  # 把 note 中的内容打成 zip 包，返回磁盘文件路径
  def zip_pack(commit_id = "master")
    zip_path = File.join(Dir::tmpdir,UUIDTools::UUID.random_create.to_s)
    zip = Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE)
    text_hash = self.text_hash(commit_id)
    
    text_hash.each do |file_name,file_content|
      zip.get_output_stream("notes_#{self.id}/#{file_name}"){|f|f.puts file_content}
    end

    zip.get_output_stream("manifest") do |f|
      f.puts "#{self.id}";f.puts "#{commit_id}";f.puts ""
      text_hash.each{|file_name,file_content|f.puts file_name}
    end

    zip.close
    return zip_path
  end
  
  after_create :init_repo
  after_destroy :delete_repo

  module UserMethods
    def self.included(base)
      base.has_many :notes
    end
  end
  include NoteRepositoryMethods
end
