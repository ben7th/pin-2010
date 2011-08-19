class PostVote < UserAuthAbstract
  belongs_to :user
  belongs_to :post
  validates_presence_of :user
  validates_presence_of :post
  validates_uniqueness_of :user_id, :scope => :post_id

  UP = "UP"
  DOWN = "DOWN"

  def is_vote_up?
    self.status == PostVote::UP
  end

  def is_vote_down?
    self.status == PostVote::DOWN
  end

  module PostMethods
    def self.included(base)
      base.has_many :post_votes,:foreign_key=>:post_id
      base.has_many :post_up_votes,:foreign_key=>:post_id,
        :class_name=>"PostVote",
        :conditions=>"post_votes.status = '#{PostVote::UP}' "
      base.has_many :post_down_votes,:foreign_key=>:post_id,
        :class_name=>"PostVote",
        :conditions=>"post_votes.status = '#{PostVote::DOWN}' "
      base.has_many :voted_up_users,:through=>:post_votes,:source=>:user,
        :conditions=>"post_votes.status = '#{PostVote::UP}' "
      base.has_many :voted_down_users,:through=>:post_votes,:source=>:user,
        :conditions=>"post_votes.status = '#{PostVote::DOWN}' "
    end

    def has_user_up?
      self.post_up_votes.count > 0
    end
    
    def vote_up(user)
      return if voted_up_by?(user)
      
      cancel_vote(user) if voted_down_by?(user)
      PostVote.create(:user=>user,:post=>self,:status=>PostVote::UP)
      update_vote_score_by_post_votes
    end
    
    def vote_down(user)
      return if voted_down_by?(user)

      cancel_vote(user) if voted_up_by?(user)
      PostVote.create(:user=>user,:post=>self,:status=>PostVote::DOWN)
      update_vote_score_by_post_votes
    end

    def cancel_vote(user)
      return if self.user == user
      vote = self.post_votes.find_by_user_id(user.id)
      return if vote.blank?
      vote.destroy
      update_vote_score_by_post_votes
    end
    
    def voted_by?(user)
      vote = self.post_votes.find_by_user_id(user.id)
      !vote.blank?
    end

    def voted_up_by?(user)
      vote = self.post_votes.find_by_user_id_and_status(user.id,PostVote::UP)
      !vote.blank?
    end

    def voted_down_by?(user)
      vote = self.post_votes.find_by_user_id_and_status(user.id,PostVote::DOWN)
      !vote.blank?
    end

    def update_vote_score_by_post_votes
      self.reload
      up_count = self.post_up_votes.length
      down_count = self.post_down_votes.length
      vote_score = up_count - down_count
      self.vote_score = vote_score
      self.save_without_timestamping
    end
  end

end
