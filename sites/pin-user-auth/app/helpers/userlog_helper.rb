module UserlogHelper

  def userlog_partial(log)
    render 'index/userlog/info_userlog',:log=>log
  rescue Exception => ex
    "用户活动记录解析错误 #{ex}" if Rails.env.development?
  end

  def userlog_ct(log)
    re = []
    if logged_in? && current_user == log.user
      re << link_to('我',current_user)
    else
      re << usersign(log.user,false)
    end

    info = log.info
    case info.kind
    when 'ADD_FEED'
      re << _userlog_ct_add_feed(info)
    when 'EDIT_FEED'
      re << _userlog_ct_edit_feed(info)
    when 'ADD_VIEWPOINT'
      re << _userlog_ct_add_viewpoint(info)
    when 'EDIT_VIEWPOINT'
      re << _userlog_ct_edit_viewpoint(info)
    when 'ADD_CONTACT'
      re << _userlog_ct_add_contact(info)
    else
      re << info.kind
    end

    re * ' '
  end

  def _userlog_ct_add_feed(info)
    re = []
    feed = info.feed
    re << '创建了主题'
    re << link_to(h(truncate_u(feed.content,32)),feed)
    re * ' '
  end

  def _userlog_ct_edit_feed(info)
    re = []
    feed = info.feed
    re << '修改了主题'
    re << link_to(h(truncate_u(feed.content,32)),feed)
    re * ' '
  end

  def _userlog_ct_add_viewpoint(info)
    re = []
    feed = info.feed
    re << '在主题'
    re << link_to(h(truncate_u(feed.content,32)),feed)
    re << '中发表了观点'
  end

  def _userlog_ct_edit_viewpoint(info)
    re = []
    feed = info.feed
    re << '编辑了主题'
    re << link_to(h(truncate_u(feed.content,32)),feed)
    re << '中的观点'
  end

  def _userlog_ct_add_contact(info)
    re = []
    user = info.contact_user
    re << '关注了'
    re << avatar(user,:mini)
    re << link_to(user.name,user)
  end

  def userlog_footmisc(log)
    re = []

    re << "<div class='time'>#{jtime(log.created_at)}</div>"

    info = log.info
    case info.kind
    when 'ADD_VIEWPOINT','EDIT_VIEWPOINT'
      re << %~
        <div class="viewpoint">
          <div class="arrow"></div>
          <div class="data">
            #{viewpoint_memo_format_in_list(info.viewpoint)}
          </div>
        </div>
      ~
    end

    re * ' '
  end

end
