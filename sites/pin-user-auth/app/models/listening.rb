class Listening < ActiveRecord::Base

  belongs_to :user
  belongs_to :channel

  validate_on_create :check_same_record
  def check_same_record
    listenings = Listending.find_all_by_user_id_and_channel_id(self.user_id,self.channel_id)
    errors.add(:base,"重复创建") if !listenings.blank?
  end

  module UserMethods
    def self.included(base)
      base.has_many :listenings
      base.has_many :listening_channels,:through=>:listenings, :source=>"channel"
    end
  end

end
