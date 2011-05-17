ActiveRecord::Base.transaction do
  Organization.all.each do |org|
    user = org.owners.first
    next if user.blank?
    member_users = org.all_member_users-[user]
    channel = Channel.new(:name=>org.name,:creator_email=>user.email)
    next if !channel.save

    member_users.each do |u|
      c = user.contacts.new(:email=>u.email)
      c.save
    end

    contacts = member_users.map do |mu|
      Contact.find_by_user_id_and_email(user.id,mu.email)
    end.compact.uniq
    channel.contacts = contacts
  end
end
