class Favorite < ActiveRecord::Base
  belongs_to :favorable,:polymorphic => true
  belongs_to :user

  def _space_of_time_over?
    (self.updated_at + _space_of_time) < Time.now
  end

  def _space_of_time
    24*60*60
  end

  module FavorableMethods
    def self.included(base)
      base.has_many :favorites,:as=>:favorable
    end

    def favor(user)
      return false if user.blank?
      favorite = self.favorites.find_by_user_id(user.id)
      if favorite.blank?
        self.favorites.create!(:user=>user,:num=>1)
        return true
      end
      if favorite._space_of_time_over?
        favorite.update_attribute(:num,favorite.num+1)
        return true
      end
      return false
    end

    # 被顶的总数
    def favor_count
      self.favorites.inject(0){|count,favorite|count + favorite.num}
    end
  end
end
