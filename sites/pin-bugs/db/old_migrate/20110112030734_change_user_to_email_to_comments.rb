class ChangeUserToEmailToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :creator_email, :string
    add_column :comments , :reply_to_email, :string

    Comment.all.each_with_index do |comment,index|
      begin
        p index+1
        user = User.find_by_id(comment.creator_id)
        creator_email = user ? user.email : nil

        reply = User.find_by_id(comment.reply_to)
        reply_to_email = reply ? reply.email : nil

        comment.creator_email = creator_email
        comment.reply_to_email = reply_to_email
        comment.save
      rescue Exception => ex
        File.open("#{RAILS_ROOT}/log/migrate_comments.log","a") do |f|
          f << "comment #{comment.id} 出错了"
          f << ex.message
          f << "\n"
        end
      end
    end
    remove_column(:comments, :creator_id)
    remove_column(:comments, :reply_to)
  end

  def self.down
  end
end
