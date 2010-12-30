module ConcatsControllerMethods
  # 已经增加为联系人 的 email_actor
  def already_contact_email_actors(emails)
    emails.select { |email| !current_user_not_contact?(email) }.map do |email|
      EmailActor.new(email)
    end
  end

  # 未加为 联系人 的 未注册用户
  def not_contact_not_regeist_email_actors(emails)
    emails.select do |email|
      current_user_not_contact?(email) && !regeist?(email)
    end.map do |email|
      EmailActor.new(email)
    end
  end

    # 未加为 联系人 的 注册用户
  def not_contacts_already_regeist_email_actors(emails)
    emails.select do |email|
      current_user_not_contact?(email) && regeist?(email)
    end.map do |email|
      EmailActor.new(email)
    end
  end

  def current_user_not_contact?(email)
    !current_user.concats.find_by_email(email)
  end

  def regeist?(email)
    EmailActor.new(email).signed_in?
  end
end