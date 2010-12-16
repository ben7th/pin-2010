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

  # 公有和私有的 web 访问路径不同
  # 这个方法可以根据 公私 生成 合适的 nid
  def nid
    self.private ? self.private_id : self.id
  end

  before_create :set_private_id
  def set_private_id
    self.private_id = randstr(20) if self.private
  end

  after_create :init_repo

  after_destroy :delete_repo
  after_destroy :delete_lucene_index
  def delete_lucene_index
    NoteLucene.delete_index(self)
  end

  module UserMethods
    def self.included(base)
      base.has_many :notes
    end
  end
  include NoteRepositoryMethods
end
