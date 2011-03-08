module MindmapRightsMethods
  def has_edit_rights?(user)
    user && (( self.user_id == user.id) || self.cooperate_edit?(user))
  end

  def has_view_rights?(user)
    !self.private ||
      (user && (
        (self.user_id == user.id) ||
        self.cooperate_view?(user) ||
        self.cooperate_edit?(user)
      ))
  end

end