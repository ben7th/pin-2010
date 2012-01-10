module MindmapRightsMethods
  
  def has_edit_rights?(user)
    return false if user.blank?
    return (self.user_id == user.id)
  end

  def has_view_rights?(user)
    return true if !self.private?

    return false if user.blank?
    return (self.user_id == user.id)
  end

end