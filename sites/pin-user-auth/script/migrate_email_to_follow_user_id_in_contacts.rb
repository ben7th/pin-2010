Contact.transaction do
  contacts = Contact.all
  count = contacts.length
  contacts.each_with_index do |contact,index|
    p "正在转换 #{index+1}/#{count}"
    follow_user = EmailActor.get_user_by_email(contact.email)
    if !follow_user.blank? && !contact.user.blank?
      contact.follow_user_id = follow_user.id
      contact.save!
    end
  end
end