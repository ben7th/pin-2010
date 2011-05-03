class ViewpointVote < UserAuthAbstract
  belongs_to :user
  belongs_to :viewpoint,:class_name=>"TodoUser"
  validates_presence_of :user
  validates_presence_of :viewpoint
  validates_uniqueness_of :user_id, :scope => :viewpoint_id

  UP = "UP"
  DOWN = "DOWN"

  def update_to_up
    if self.status != ViewpointVote::UP
      self.update_attribute(:status,ViewpointVote::UP)
    end
  end

  def update_to_down
    if self.status != ViewpointVote::DOWN
      self.update_attribute(:status,ViewpointVote::DOWN)
    end
  end

  module TodoUserMethods
    def self.included(base)
      base.has_many :viewpoint_votes,:foreign_key=>:viewpoint_id
      base.has_many :up_viewpoint_votes,:foreign_key=>:viewpoint_id,
        :class_name=>"ViewpointVote",
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::UP}' "
      base.has_many :down_viewpoint_votes,:foreign_key=>:viewpoint_id,
        :class_name=>"ViewpointVote",
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::DOWN}' "
      base.has_many :voted_up_users,:through=>:viewpoint_votes,:source=>:user,
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::UP}' "
      base.has_many :voted_down_users,:through=>:viewpoint_votes,:source=>:user,
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::DOWN}' "
    end
    
    def vote_up(user)
      return if self.user == user
      vote = self.viewpoint_votes.find_by_user_id(user.id)
      if vote.blank?
        ViewpointVote.create(:user=>user,:viewpoint=>self,:status=>ViewpointVote::UP)
      else
        vote.update_to_up
      end
      update_vote_score_by_viewpoint_votes
    end
    
    def vote_down(user)
      return if self.user == user
      vote = self.viewpoint_votes.find_by_user_id(user.id)
      if vote.blank?
        ViewpointVote.create(:user=>user,:viewpoint=>self,:status=>ViewpointVote::DOWN)
      else
        vote.update_to_down
      end
      update_vote_score_by_viewpoint_votes
    end
    
    def voted_by?(user)
      vote = self.viewpoint_votes.find_by_user_id(user.id)
      !vote.blank?
    end

    def voted_up_by?(user)
      vote = self.viewpoint_votes.find_by_user_id_and_status(user.id,ViewpointVote::UP)
      !vote.blank?
    end

    def voted_down_by?(user)
      vote = self.viewpoint_votes.find_by_user_id_and_status(user.id,ViewpointVote::DOWN)
      !vote.blank?
    end

    def update_vote_score_by_viewpoint_votes
      up_count = self.up_viewpoint_votes.length
      down_count = self.down_viewpoint_votes.length
      vote_score = up_count - down_count
      self.update_attribute(:vote_score,vote_score)
    end
  end
end
