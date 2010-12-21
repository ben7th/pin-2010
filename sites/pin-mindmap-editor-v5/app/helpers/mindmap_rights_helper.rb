module MindmapRightsHelper
  def add_nobody_mindmap_to_cookies(mindmap)
    mindmap_ids = get_nobody_mindmap_ids_from_cookies
    mindmap_ids << mindmap.id
    cookies[:nmids] = {:value=>mindmap_ids.uniq.to_json,:expires=>1.year.from_now,:domain=>'mindpin.com'}
  end

  def get_nobody_mindmap_ids_from_cookies
    ActiveSupport::JSON.decode(cookies[:nmids] || "[]")
  end

  def clear_nobody_mindmap_ids_from_cookies
    cookies[:nmids] = {:value=>[].to_json,:domain=>'mindpin.com'}
  end

  def is_nobody_mindmap_of_current_cookies(mindmap)
    is_nobody_mindmap = mindmap.user_id == 0
    cookies_include = get_nobody_mindmap_ids_from_cookies.include?(mindmap.id)
    is_nobody_mindmap && cookies_include
  end

  def has_edit_rights?(mindmap,user)
    has_edit_rights_by_owner(mindmap,user) || mindmap.cooperate_edit?(user)
  end

  def has_view_rights?(mindmap,user)
    !mindmap.private || !!user && mindmap.private && (mindmap.cooperate_view?(user) || mindmap.cooperate_edit?(user))
  end

  def has_edit_rights_by_owner(mindmap,user)
    is_nobody_mindmap_of_current_cookies(mindmap) || (user && mindmap.user_id == user.id)
  end
end