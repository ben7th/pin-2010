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
end
