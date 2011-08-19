module QueueMethods

  def create_tip(kind,args)
    case kind
    when UserTipProxy::FAVS_EDIT_FEED_CONTENT
      feed_revision = FeedRevision.find_by_id(args.first)
      return if feed_revision.blank?
      self.create_favs_edit_feed_content_tip(feed_revision)
    when UserTipProxy::FAVS_ADD_POST
      post = Post.find_by_id(args.first)
      return if post.blank?
      self.create_favs_add_post_tip(post)
    when UserTipProxy::FAVS_EDIT_POST
      post = Post.find_by_id(args.first)
      return if post.blank?
      self.create_fav_edit_post_tip(post)
    when UserTipProxy::FEED_INVITE
      feed_invite = FeedInvite.find_by_id(args.first)
      return if feed_invite.blank?
      self.create_feed_invite_tip(feed_invite)
    when UserTipProxy::POST_VOTE_UP
      post_vote = PostVote.find_by_id(args.first)
      return if post_vote.blank?
      self.create_post_vote_up_tip(post_vote)
    when UserTipProxy::POST_SPAM_MARK_EFFECT
      post = Post.find_by_id(args.first)
      return if post.blank?
      self.create_post_spam_mark_effect_tip(post)
    when UserTipProxy::FEED_SPAM_MARK_EFFECT
      feed = Feed.find_by_id(args.first)
      return if feed.blank?
      self.create_feed_spam_mark_effect_tip(feed)
    when UserTipProxy::POST_COMMENT
      tc = PostComment.find_by_id(args.first)
      return if tc.blank?
      self.create_post_comment_tip(tc)
    when UserTipProxy::ATME
      atme = Atme.find_by_id(args.first)
      return if atme.blank?
      self.create_atme_tip(atme)
    when UserTipProxy::BE_FOLLOWED
      channel_user = ChannelUser.find_by_id(args.first)
      return if channel_user.blank?
      self.create_be_followed_tip(channel_user)
    end
  end

end
