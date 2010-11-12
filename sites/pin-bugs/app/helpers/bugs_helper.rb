module BugsHelper
  def browser_type_class(bug)
    browser_str = bug.browser_type
    if browser_str.match("MSIE")
      return "ua_ie_icon_48"
    elsif browser_str.match("Firefox")
      return "ua_firefox_icon_48"
    elsif browser_str.match("Chrome")
      return "ua_chrome_icon_48"
    elsif browser_str.match("Safari")
      return "ua_safari_icon_48"
    else
      return "ua_unknown_48"
    end
  end

  def bug_commiter(bug)
    "#{bug.user.blank? ? bug.handled_user_ip : bug.user.email}"
  end

  def bug_commiter_logo(bug)
    logo(bug.user,:tiny)
  end

  def bug_attachment(bug)
    if bug.attachment_file_name
      "<div class='attachment margint5'><img class='logo' alt='' src='#{bug.attachment.url('medium')}'/></div>"
    end
  end

  def bug_status_icon(bug)
    return '<div class="closed"></div>' if bug.closed?
    '<div class="handled"></div>' if bug.handled?
  end

end
