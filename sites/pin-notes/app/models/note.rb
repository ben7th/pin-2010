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

  def title
    "note:#{self.id}"
  end

  def repo
    NoteRepository.find(:user_id=>user_id,:note_id=>id)
  end

  # note 版本库中的 文件的地址列表
  def repo_file_name_list
    file_path_list = Dir.entries(self.repo.path)
    file_path_list.delete(".")
    file_path_list.delete("..")
    file_path_list.delete(".git")
    file_path_list
  end

  # 把 note 中的内容打成 zip 包,返回地址
  def zip_pack
    zip_path = File.join(Dir::tmpdir,UUIDTools::UUID.random_create.to_s)
    zip = Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE)
    base_path = self.repo.path
    
    repo_file_name_list.each do |file_name|
      zip.add("notes_#{self.id}/#{file_name}.txt",File.join(base_path,file_name))
    end

    zip.close
    return zip_path
  end
  
  after_create :create_repo
  def create_repo
    NoteRepository.create(:user_id=>user_id,:note_id=>id)
  end

  after_destroy :destroy_repo
  def destroy_repo
    repo.destroy
  end

  module UserMethods
    def self.included(base)
      base.has_many :notes
    end
  end
end
