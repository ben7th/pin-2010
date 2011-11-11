comments = PostComment.all
comments_count = comments.count

def PostComment.record_timestamps
  false
end

comments.each_with_index do |comment, index|
  p "正在处理 #{index+1}/#{comments_count}"

  if(!comment.reply_to_comment.blank?)
    comment.reply_to_user = comment.reply_to_comment.user

    def comment.record_timestamps
      false
    end

    comment.save
  end
end
