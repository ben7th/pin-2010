class ViewpointVote < UserAuthAbstract
  belongs_to :user
  belongs_to :viewpoint,:class_name=>"TodoUser"
  validates_presence_of :user
  validates_presence_of :viewpoint
  validates_uniqueness_of :user_id, :scope => :viewpoint_id

  UP = "UP"
  DOWN = "DOWN"

  def is_vote_up?
    self.status == ViewpointVote::UP
  end

  def is_vote_down?
    self.status == ViewpointVote::DOWN
  end

  module TodoUserMethods
    def self.included(base)
      base.has_many :viewpoint_votes,:foreign_key=>:viewpoint_id
      base.has_many :viewpoint_up_votes,:foreign_key=>:viewpoint_id,
        :class_name=>"ViewpointVote",
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::UP}' "
      base.has_many :viewpoint_down_votes,:foreign_key=>:viewpoint_id,
        :class_name=>"ViewpointVote",
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::DOWN}' "
      base.has_many :voted_up_users,:through=>:viewpoint_votes,:source=>:user,
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::UP}' "
      base.has_many :voted_down_users,:through=>:viewpoint_votes,:source=>:user,
        :conditions=>"viewpoint_votes.status = '#{ViewpointVote::DOWN}' "
    end

    def has_user_up?
      self.viewpoint_up_votes.count > 0
    end
    
    def vote_up(user)
      return if voted_up_by?(user)
      
      cancel_vote(user) if voted_down_by?(user)
      ViewpointVote.create(:user=>user,:viewpoint=>self,:status=>ViewpointVote::UP)
      update_vote_score_by_viewpoint_votes
    end
    
    def vote_down(user)
      return if voted_down_by?(user)

      cancel_vote(user) if voted_up_by?(user)
      ViewpointVote.create(:user=>user,:viewpoint=>self,:status=>ViewpointVote::DOWN)
      update_vote_score_by_viewpoint_votes
    end

    def cancel_vote(user)
      return if self.user == user
      vote = self.viewpoint_votes.find_by_user_id(user.id)
      return if vote.blank?
      vote.destroy
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
      self.reload
      up_count = self.viewpoint_up_votes.length
      down_count = self.viewpoint_down_votes.length
      vote_score = up_count - down_count
      self.vote_score = vote_score
      self.save_without_timestamping
    end
  end

end
