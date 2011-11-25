class FeedVote < UserAuthAbstract
  belongs_to :user
  belongs_to :feed
  validates_presence_of :user
  validates_presence_of :feed
  validates_uniqueness_of :user_id, :scope => :feed_id

  UP = "UP"
  DOWN = "DOWN"

  def is_vote_up?
    self.status == UP
  end

  def is_vote_down?
    self.status == DOWN
  end

  module FeedMethods
    def self.included(base)
      base.has_many :feed_votes
      base.has_many :feed_up_votes,:class_name=>"FeedVote",
        :conditions=>"feed_votes.status = '#{FeedVote::UP}' "
      base.has_many :feed_down_votes,:class_name=>"FeedVote",
        :conditions=>"feed_votes.status = '#{FeedVote::DOWN}' "
      base.has_many :voted_up_users,:through=>:feed_votes,:source=>:user,
        :conditions=>"feed_votes.status = '#{FeedVote::UP}' "
      base.has_many :voted_down_users,:through=>:feed_votes,:source=>:user,
        :conditions=>"feed_votes.status = '#{FeedVote::DOWN}' "
    end

    def vote_up(user)
      return if voted_up_by?(user)

      cancel_vote(user) if voted_down_by?(user)
      self.feed_votes.create(:user=>user,:status=>FeedVote::UP)
      update_vote_score_by_feed_votes
    end

    def vote_down(user)
      return if voted_down_by?(user)

      cancel_vote(user) if voted_up_by?(user)
      self.feed_votes.create(:user=>user,:status=>FeedVote::DOWN)
      update_vote_score_by_feed_votes
    end

    def cancel_vote(user)
      return if self.user == user
      vote = self.feed_votes.find_by_user_id(user.id)
      return if vote.blank?
      vote.destroy
      update_vote_score_by_feed_votes
    end

    def voted_by?(user)
      vote = self.feed_votes.find_by_user_id(user.id)
      !vote.blank?
    end

    def voted_up_by?(user)
      vote = self.feed_votes.find_by_user_id_and_status(user.id,FeedVote::UP)
      !vote.blank?
    end

    def voted_down_by?(user)
      vote = self.feed_votes.find_by_user_id_and_status(user.id,FeedVote::DOWN)
      !vote.blank?
    end

    def update_vote_score_by_feed_votes
      self.reload
      up_count = self.feed_up_votes.count
      down_count = self.feed_down_votes.count
      vote_score = up_count - down_count
      self.vote_score = vote_score
      self.save_without_timestamping
    end
  end
end
