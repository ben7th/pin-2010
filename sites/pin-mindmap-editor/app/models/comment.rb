# == Schema Information
# Schema version: 20081118030512
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  title            :string(50)      default("")
#  comment          :string(255)     default("")
#  created_at       :datetime        not null
#  commentable_id   :integer(4)      default(0), not null
#  commentable_type :string(15)      default(""), not null
#  user_id          :integer(4)      default(0), not null
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true

  validates_presence_of :comment
  
  # NOTE: install the acts_as_votable plugin if you 
  # want user to vote on the quality of comments.
  #acts_as_voteable
  
  # NOTE: Comments belong to a user
  belongs_to :user
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  # Helper class method to look up all comments for 
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    find(:all,
      :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
      :order => "created_at DESC"
    )
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id 
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  module CommentableMethods
    def self.included(base)
      base.has_many :comments,:as=>:commentable
    end

    def add_comment(comment)
      # self.comments << comment
      Comment.create(:title=>comment.title,:comment=>comment.comment,:user_id=>comment.user_id,:commentable_id=>self.id,:commentable_type=>self.class.to_s)
    end
  end
end
