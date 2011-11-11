module ApiCommentMethods

  # 获取指定主题的评论列表
  # :feed_id 必须 主题的id
  def feed_comments
    feed = Feed.find(params[:feed_id])
    comments = feed.main_post.comments
    return render :json=>comments.map{|comment|
      api0_comment_json_hash(comment)
    }
  end

  # 添加一条评论
  # :feed_id 必须 主题的id
  # :content 必须，评论正文内容
  def create_comment
    feed = Feed.find(params[:feed_id])
    comment = feed.add_comment(current_user,params[:content])
    return render :json=>api0_comment_json_hash(comment)
  rescue Exception => ex
    render :text=>ex.message, :status=>400
  end

  # 删除一条评论
  # :comment_id 必须 评论的id
  def delete_comment
    comment = PostComment.find(params[:comment_id])
    if comment.can_be_deleted_by?(current_user)
      comment.destroy
      return render :json=>api0_comment_json_hash(comment)
    end
    render :text=>'你不能删除这条评论',:status=>403
  rescue Exception => ex
    render :text=>ex.message, :status=>400
  end

  # 回复一条评论
  # :comment_id 必须 被回复的评论的id
  # :content 必须，评论正文内容
  # 通过此api回复时，评论content前面会自动加上 "回复@用户名:" 因此客户端不用特别处理
  def reply_comment
    reply_to_comment = PostComment.find(params[:comment_id])
    reply_content = "回复@#{reply_to_comment.user.name}:#{params[:content]}"
    comment = reply_to_comment.add_reply(current_user, reply_content)
    return render :json=>api0_comment_json_hash(comment)
  rescue Exception => ex
    render :text=>ex.message, :status=>400
  end

  # 查询当前用户收到的评论
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的comment信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的comment信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def comments_received
    comments = current_user.comments_received({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    return render :json=>comments.map{|comment|
      api0_comment_json_hash(comment)
    }
  end

  # 查询当前用户发出的评论
  # :since_id 非必须，若指定此参数，则只获取ID比since_id大的comment信息
  # :max_id 非必须，若指定此参数，则只获取ID小于或等于max_id的comment信息
  # :count 非必须 默认20，最大100，单页返回的结果条数
  # :page 非必须，返回结果的页码，默认1
  def comments_sent
    comments = current_user.comments_sent({
      :since_id => params[:since_id],
      :max_id   => params[:max_id],
      :count    => params[:count],
      :page     => params[:page]
    })

    return render :json=>comments.map{|comment|
      api0_comment_json_hash(comment)
    }
  end

end
