class BugsAbstract < ActiveRecord::Base
  self.abstract_class = true
  build_database_connection("pin-bugs")
end

class Comment < BugsAbstract
  belongs_to :creator,:class_name => "User", :foreign_key => "creator_email", :primary_key=> "email"
  belongs_to :markable,:polymorphic => true
end

class Bug < BugsAbstract
  def comments
    Comment.find_all_by_markable_type_and_markable_id("Bug",self.id)
  end
end
Bug.transaction do
  bugs = Bug.all
  count = bugs.length
  bugs.each_with_index do |bug,index|
    p "完成度：#{index+1}/#{count}"
    next if bug.user_id.blank?
    user = User.find_by_id(bug.user_id)
    next if user.blank? || bug.content.blank?

    feed = user.send_say_feed(bug.content,:channel_ids=>[1])
    next if feed.blank?
    bug.comments.each do |comment|
      next if comment.creator.blank? || comment.content.blank?
      Feed.reply_to_feed(comment.creator,comment.content,false,feed)
    end
  end
end
