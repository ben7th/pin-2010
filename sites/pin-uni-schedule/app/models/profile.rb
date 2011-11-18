class Profile < ActiveRecord::Base
  belongs_to :user

  belongs_to :university

  module UserMethods
    def self.included(base)
      base.has_one :profile
    end

    def has_university?
      profile = self.profile
      !profile.blank? && !profile.university.blank?
    end

    def set_university(university)
      profile = self.profile
      if profile.blank?
        Profile.create(:user=>self,:university=>university)
      else
        profile.university = university
        profile.save
      end
    end
  end
end
