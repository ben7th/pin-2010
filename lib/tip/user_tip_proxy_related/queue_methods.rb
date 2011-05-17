module QueueMethods
  # 在 队列中 增加 收藏的话题被修改 提示
  def create_favs_edit_feed_content_tip_on_queue(feed_change)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,[feed_change.id])
  end

  # 在 队列中 增加 收藏的话题有新观点 提示
  def create_favs_add_viewpoint_tip_on_queue(viewpoint)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_ADD_VIEWPOINT,[viewpoint.id])
  end

  # 在 队列中 增加 收藏的话题的观点被修改 提示
  def create_fav_edit_viewpoint_tip_on_queue(viewpoint)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FAVS_EDIT_VIEWPOINT,[viewpoint.id])
  end

  # 在 队列中 增加 被邀请参加话题 提示
  def create_feed_invite_tip_on_queue(feed_invite)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FEED_INVITE,[feed_invite.id])
  end

  # 在 队列中 增加 发表的观点被赞同 提示
  def create_viewpoint_vote_up_tip_on_queue(viewpoint_vote)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_VOTE_UP,[viewpoint_vote.id])
  end

  # 在 队列中 增加 观点被确认 不值得讨论  提示
  def create_viewpoint_spam_mark_effect_tip_on_queue(viewpoint)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT,[viewpoint.id])
  end

  # 在 队列中 增加 话题被确认 不值得讨论 提示
  def create_feed_spam_mark_effect_tip_on_queue(feed)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::FEED_SPAM_MARK_EFFECT,[feed.id])
  end

  # 在 队列中 增加 观点讨论 提示
  def create_viewpoint_comment_tip_on_queue(tc)
    UserTipResqueQueueWorker.async_user_tip(UserTipProxy::VIEWPOINT_COMMENT,[tc.id])
  end

  def create_tip(kind,args)
    case kind
    when UserTipProxy::FAVS_EDIT_FEED_CONTENT
      feed_change = FeedChange.find_by_id(args.first)
      return if feed_change.blank?
      self.create_favs_edit_feed_content_tip(feed_change)
    when UserTipProxy::FAVS_ADD_VIEWPOINT
      viewpoint = TodoUser.find_by_id(args.first)
      return if viewpoint.blank?
      self.create_favs_add_viewpoint_tip(viewpoint)
    when UserTipProxy::FAVS_EDIT_VIEWPOINT
      viewpoint = TodoUser.find_by_id(args.first)
      return if viewpoint.blank?
      self.create_fav_edit_viewpoint_tip(viewpoint)
    when UserTipProxy::FEED_INVITE
      feed_invite = FeedInvite.find_by_id(args.first)
      return if feed_invite.blank?
      self.create_feed_invite_tip(feed_invite)
    when UserTipProxy::VIEWPOINT_VOTE_UP
      viewpoint_vote = ViewpointVote.find_by_id(args.first)
      return if viewpoint_vote.blank?
      self.create_viewpoint_vote_up_tip(viewpoint_vote)
    when UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT
      viewpoint = TodoUser.find_by_id(args.first)
      return if viewpoint.blank?
      self.create_viewpoint_spam_mark_effect_tip(viewpoint)
    when UserTipProxy::FEED_SPAM_MARK_EFFECT
      feed = Feed.find_by_id(args.first)
      return if feed.blank?
      self.create_feed_spam_mark_effect_tip(feed)
    when UserTipProxy::VIEWPOINT_COMMENT
      tc = TodoMemoComment.find_by_id(args.first)
      return if tc.blank?
      self.create_viewpoint_comment_tip(tc)
    end
  end

  def create_favs_tip(kind,feed,operator)
    users = feed.fav_users
    (users-[operator]).each do |user|
      UserTipProxy.new(user).create_favs_tip(kind,feed,operator)
    end
  end

  # 增加 收藏的话题被修改 提示
  def create_favs_edit_feed_content_tip(feed_change)
    feed = feed_change.feed
    operator = feed_change.user
    self.create_favs_tip(UserTipProxy::FAVS_EDIT_FEED_CONTENT,feed,operator)
  end

  # 收藏的话题有新观点
  def create_favs_add_viewpoint_tip(viewpoint)
    feed = viewpoint.feed
    operator = viewpoint.user
    self.create_favs_tip(UserTipProxy::FAVS_ADD_VIEWPOINT,feed,operator)
  end

  # 收藏的话题的观点被修改
  def create_fav_edit_viewpoint_tip(viewpoint)
    feed = viewpoint.feed
    operator = viewpoint.user
    self.create_favs_tip(UserTipProxy::FAVS_EDIT_VIEWPOINT,feed,operator)
  end

  # 被邀请参加话题
  def create_feed_invite_tip(feed_invite)
    feed = feed_invite.feed
    creator = feed_invite.creator
    user = feed_invite.user

    UserTipProxy.new(user).create_feed_invite_tip(feed,creator)
  end

  # 发表的观点被赞同
  def create_viewpoint_vote_up_tip(viewpoint_vote)
    viewpoint = viewpoint_vote.viewpoint
    voter = viewpoint_vote.user

    UserTipProxy.new(viewpoint.user).create_viewpoint_vote_up_tip(viewpoint,voter)
  end

  def create_viewpoint_spam_mark_effect_tip(viewpoint)
    UserTipProxy.new(viewpoint.user).create_viewpoint_spam_mark_effect_tip(viewpoint)
  end

  def create_feed_spam_mark_effect_tip(feed)
    UserTipProxy.new(feed.creator).create_feed_spam_mark_effect_tip(feed)
  end

  def create_viewpoint_comment_tip(viewpoint_comment)
    UserTipProxy.new(viewpoint_comment.todo_user.user).create_viewpoint_comment_tip(viewpoint_comment)
  end

  def destroy_feed_invite_tip(feed_invite)
    feed = feed_invite.feed
    creator = feed_invite.creator

    UserTipProxy.new(feed_invite.user).destroy_feed_invite_tip(feed,creator)
  end

  def destroy_viewpoint_vote_up_tip(viewpoint_vote)
    viewpoint = viewpoint_vote.viewpoint
    voter = viewpoint_vote.user
    self.new(viewpoint.user).destroy_viewpoint_vote_up_tip(viewpoint,voter)
  end
end
