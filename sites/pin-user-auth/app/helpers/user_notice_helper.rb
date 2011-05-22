module UserNoticeHelper

#  UserTipProxy::FEED_INVITE
#
#  UserTipProxy::FAVS_EDIT_FEED_CONTENT
#  UserTipProxy::FAVS_ADD_VIEWPOINT
#  UserTipProxy::FAVS_EDIT_VIEWPOINT
#  
#  UserTipProxy::VIEWPOINT_VOTE_UP
#  UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT
#
#  UserTipProxy::FEED_SPAM_MARK_EFFECT  :id,:feed,:kind,:time
#  UserTipProxy::VIEWPOINT_COMMENT :id,:feed,:viewpoint,:viewpoint_comment,:user

  def user_tip_str(tip)
    re = case tip.kind

    when UserTipProxy::FEED_INVITE
      be_invited_tip_str(tip)

    when UserTipProxy::FAVS_EDIT_FEED_CONTENT
      fav_edit_feed_content_str(tip)

    when UserTipProxy::FAVS_ADD_VIEWPOINT
      fav_add_viewpoint_str(tip)

    when UserTipProxy::FAVS_EDIT_VIEWPOINT
      fav_edit_viewpoint_str(tip)

    when UserTipProxy::VIEWPOINT_VOTE_UP
      vote_up_tip_str(tip)

    when UserTipProxy::VIEWPOINT_SPAM_MARK_EFFECT
      viewpoint_span_mark_effect(tip)

    when UserTipProxy::FEED_SPAM_MARK_EFFECT
      feed_spam_mark_effect_str(tip)

    when UserTipProxy::VIEWPOINT_COMMENT
      viewpoint_comment_str(tip)

    else
      ['<del class="quiet">通知已失效</del>']
      
    end

    re << "<span class='quiet'>#{jtime tip.time}</span>"
    return re*' '

  rescue Exception => ex
    return "提示信息解析错误#{ex}" if RAILS_ENV == 'development'
#    return '　'
    "提示信息解析错误#{ex}"
  end

  # 被邀请的通知
  def be_invited_tip_str(be_invited_tip)
    # id feed creator

    user = be_invited_tip.creator
    feed = be_invited_tip.feed

    re = []
    re << usersign(user,false)
    re << '邀请你参与话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
  end

  def fav_edit_feed_content_str(fav_change_tip)
    # :tip_id,:feed,:user,:kind,:time

    user = fav_change_tip.user
    feed = fav_change_tip.feed
    
    re = []
    re << usersign(user,false)
    re << '修改了话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
  end

  def fav_add_viewpoint_str(fav_change_tip)
    user = fav_change_tip.user
    feed = fav_change_tip.feed

    re = []
    re << usersign(user,false)
    re << '在话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << "中发表了观点"
  end

  def fav_edit_viewpoint_str(fav_change_tip)
    user = fav_change_tip.user
    feed = fav_change_tip.feed

    re = []
    re << usersign(user,false)
    re << '在话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << "中修改了观点"
  end

  def vote_up_tip_str(vote_tip)
    voters = vote_tip.voters
    feed = vote_tip.viewpoint.todo.feed

    re = []

    vre = []
    voters.each do |voter|
      vre << usersign(voter,false)
    end

    re << vre*','
    re << '对于你在话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << '中的观点表示赞成'
  end

  def viewpoint_span_mark_effect(tip)
    feed = tip.feed
    viewpoint = tip.viewpoint

    re = []
    re << '你的观点'
    re << link_to(h(truncate_u(viewpoint.memo,16)),feed)
    re << '因为被认为没有帮助而被隐藏'
  end

  def feed_spam_mark_effect_str(tip)
    # :id,:feed,:kind,:time
    feed = tip.feed

    re = []
    re << '你的话题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << '因为被认为不值得讨论而被隐藏'
  end

  def viewpoint_comment_str(tip)
    # :id,:feed,:viewpoint,:viewpoint_comment,:user
    user = tip.user
    feed = tip.feed
    viewpoint = tip.viewpoint

    re = []
    re << usersign(user,false)
    re << '对你的观点'
    re << link_to(h(truncate_u(viewpoint.memo,16)),feed)
    re << '添加了评论'
  end

end
