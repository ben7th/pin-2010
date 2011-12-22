module MindmapRightsHelper

  def has_edit_rights?(mindmap,user)
    mindmap.has_edit_rights?(user)
  end

  def has_view_rights?(mindmap,user)
    mindmap.has_view_rights?(user)
  end

end