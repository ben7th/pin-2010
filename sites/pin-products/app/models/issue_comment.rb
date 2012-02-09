class IssueComment < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  belongs_to :reply_to_comment, :class_name=>"IssueComment", :foreign_key=>:reply_comment_id
  belongs_to :reply_to_user, :class_name=>"User", :foreign_key=>:reply_comment_user_id
  has_many :reply_comments, :class_name=>"IssueComment", :foreign_key=>:reply_comment_id
  validates_presence_of :issue
  validates_presence_of :user
  validates_presence_of :content
  
  before_save :update_reply_to_user
  def update_reply_to_user
    if(!self.reply_to_comment.blank?)
      self.reply_to_user = self.reply_to_comment.user
    end
  end
end
