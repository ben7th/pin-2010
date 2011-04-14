module MindmapRightsMethods
  def has_edit_rights?(user)
    user && (( self.user_id == user.id) || self.cooperate_with_user?(user))
  end

  def has_view_rights?(user)
    !self.private ||
      (
      user && (self.user_id == user.id || self.cooperate_with_user?(user))
    )
  end

end