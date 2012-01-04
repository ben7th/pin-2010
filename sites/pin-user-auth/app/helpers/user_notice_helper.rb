module UserNoticeHelper
  def user_tip_str(tip)
    re = case tip.kind

    when UserTipProxy::FAVS_EDIT_FEED_TITLE
      fav_edit_feed_title_str(tip)

    when UserTipProxy::FAVS_ADD_VIEWPOINT
      fav_add_viewpoint_str(tip)

    when UserTipProxy::FAVS_EDIT_VIEWPOINT
      fav_edit_viewpoint_str(tip)

    when UserTipProxy::VIEWPOINT_COMMENT
      viewpoint_comment_str(tip)

    else
      ['<del class="quiet">通知已失效</del>']
      
    end

    re << "<span class='quiet'>#{jtime tip.time}</span>"
    return re*' '

  rescue Exception => ex
    return "提示信息解析错误#{ex}" if Rails.env.development?
    "<del class='quiet'>通知已失效</del><div style='display:none;'>#{ex}</div>"
  end

  def fav_edit_feed_title_str(fav_change_tip)
    # :tip_id,:feed,:user,:kind,:time

    user = fav_change_tip.user
    feed = fav_change_tip.feed
    
    re = []
    re << usersign(user,false)
    re << '修改了主题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
  end

  def fav_add_viewpoint_str(fav_change_tip)
    user = fav_change_tip.user
    feed = fav_change_tip.feed

    re = []
    re << usersign(user,false)
    re << '在主题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << "中发表了观点"
  end

  def fav_edit_viewpoint_str(fav_change_tip)
    user = fav_change_tip.user
    feed = fav_change_tip.feed

    re = []
    re << usersign(user,false)
    re << '在主题'
    re << link_to(h(truncate_u(feed.content,16)),feed)
    re << "中修改了观点"
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
