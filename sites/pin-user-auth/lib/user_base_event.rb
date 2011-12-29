module UserBaseEvent

  def has_avatar?
    !self.logo_file_name.blank?
  end

  def has_contacts?
    self.contacts.size > 0
  end

  def has_channels?
    self.channels.size > 0
  end

  def has_feeds?
    Feed.news_feeds_of_user(self).size > 0
  end

  def activated?
    !!self.activated_at
  end

  def bind_site?
    self.has_binded_sina? || self.has_binded_renren?
  end

  def complate_percentage
    score = 0;
    score += 18 if has_avatar?
    score += 18 if has_contacts?
#    score += 15 if has_channels?
    score += 18 if has_feeds?
    score += 18 if activated?
    score += 18 if bind_site?
    return score
  end

  # 用来表示一些基础的事件有没有完成
  def base_event
    return {
      :avatar=>has_avatar?,
      :contacts=>has_contacts?,
      :activated=>activated?,
      :bind_site=>bind_site?,
      :channels=>has_channels?,
      :feeds=>has_feeds?,
      :complate_percentage=>complate_percentage
    }
  end

end
