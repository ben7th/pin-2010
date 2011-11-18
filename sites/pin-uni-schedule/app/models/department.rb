class Department < ActiveRecord::Base
  belongs_to :university
  has_many :courses

  validates_presence_of :name
  validates_presence_of :university

  def self.create_or_find(university,name)
    department = Department.find(:first,
      :conditions=>{:university_id=>university.id,
        :name=>name})
    if department.blank?
      department = Department.create(:name=>name,:university=>university)
    end
    department
  end
end
