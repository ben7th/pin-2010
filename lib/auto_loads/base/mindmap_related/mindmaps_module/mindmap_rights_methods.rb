module MindmapRightsMethods
  
  def has_edit_rights?(user)
    return false if user.blank?
    return (self.user_id == user.id) || self.cooperate_with_user?(user)
  end

  def has_view_rights?(user)
    return true if !self.private?

    return false if user.blank?
    return (self.user_id == user.id) || self.cooperate_with_user?(user)
  end

end