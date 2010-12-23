class Member < MemberBase
  
  belongs_to :organization
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"

  module UserMethods
    def self.included(base)
      base.has_many :members,:foreign_key=>"email",:primary_key=>"email"
    end
  end
end
