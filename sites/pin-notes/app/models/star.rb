class Star < ActiveRecord::Base
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"
  validates_presence_of :email
  validates_presence_of :note_id


  module UserMethods
    # 是否 star 了 这个 note
    def star_note?(note)
      Star.find_all_by_note_id_and_email(note.id,self.email).size != 0
    end

    # star 这个 note
    def star_note(note)
      return if star_note?(note)
      Star.create(:email=>self.email,:note_id=>note.id)
    end

    # unstar 这个 note
    def unstar_note(note)
      stars = Star.find_all_by_note_id_and_email(note.id,self.email)
      stars.each { |star| star.destroy }
    end

    # star 的 notes
    def starred_notes
      Note.star_of_user(self)
    end
  end
end
