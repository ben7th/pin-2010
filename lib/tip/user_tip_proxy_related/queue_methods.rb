module QueueMethods

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

end
