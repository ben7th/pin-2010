class Teacher < ActiveRecord::Base
  belongs_to :university
  has_many :course_items

  validates_presence_of :name
  validates_presence_of :tid
  validates_presence_of :university

  def self.create_or_find(university,name,tid)
    teacher = Teacher.find(:first,
      :conditions=>{:name=>name,
        :tid=>tid,:university_id=>university.id})
    if teacher.blank?
      teacher = Teacher.create(:name=>name,:tid=>tid,:university=>university)
    end
    teacher
  end

  @logo_path = "/:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "http://storage.aliyun.com/#{OssManager::CONFIG["bucket"]}/:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:styles => {
    :medium=>"96x96#",
    :normal=>"48x48#",
    :tiny=>'32x32#',
    :mini=>'24x24#'
  },
    :storage => :oss,
    :path => @logo_path,
    :url => @logo_url,
    :default_url => "/images/logo/default_:class_:style.png",
    :default_style => :normal
end
