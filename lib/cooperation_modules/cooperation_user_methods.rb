module CooperationUserMethods
  # 被别人协同编辑的导图（不包括团队协同）
  def cooperate_edit_mindmaps
    email_coos = Cooperation.find_all_by_email_and_kind(self.email,Cooperation::EDITOR).flatten
    mindpin_email_coos = Cooperation.find_all_by_email_and_kind(EmailActor.get_mindpin_email(self),Cooperation::EDITOR).flatten
    coos = email_coos | mindpin_email_coos
    mindmaps = coos.map{|coo|coo.mindmap}.compact
    mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id && !!mindmap.user}
  end

  # 被别人协同查看的导图（不包括团队协同）
  def cooperate_view_mindmaps
    email_coos = Cooperation.find_all_by_email_and_kind(self.email,Cooperation::VIEWER).flatten
    mindpin_email_coos = Cooperation.find_all_by_email_and_kind(EmailActor.get_mindpin_email(self),Cooperation::VIEWER).flatten
    coos = email_coos | mindpin_email_coos
    mindmaps = coos.map{|coo|coo.mindmap}.compact
    mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id  && !!mindmap.user}
    mindmaps.select{|mindmap|mindmap.private}
  end
end

