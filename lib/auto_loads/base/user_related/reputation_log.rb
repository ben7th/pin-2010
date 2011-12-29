class ReputationLog < UserAuthAbstract
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :kind
  validates_presence_of :info_json

  module UserMethods
    def self.included(base)
      base.has_many :reputation_logs
    end

    def add_reputation(num)
      r = self.reputation
      nr = r+num
      self.update_attributes(:reputation=>nr)
    end

  end


end
