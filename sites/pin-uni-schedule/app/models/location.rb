class Location < ActiveRecord::Base
  belongs_to :university
  has_many :course_items

  validates_presence_of :name
  validates_presence_of :university

  def self.create_or_find(university,name)
    location = Location.find(:first,
      :conditions=>{:name=>name,:university_id=>university.id})
    if location.blank?
      location = Location.create(:name=>name,:university=>university)
    end
    location
  end
end
