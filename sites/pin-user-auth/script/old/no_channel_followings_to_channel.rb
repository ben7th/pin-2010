
contact_ids = Contact.find_by_sql(%`
    select contacts.id from contacts
      left join channel_contacts on
        contacts.id = channel_contacts.contact_id
      where channel_contacts.id is null
  `).map{|c|c.id}

count = contact_ids.length
ActiveRecord::Base.transaction do

  begin
    contact_ids.each_with_index do |id,index|
      p "正在处理 #{index+1}/#{count}"
      contact = Contact.find_by_id(id)
      next if contact.blank?
      user = contact.user
      follow_user = contact.follow_user
      next if user.blank?
      next if follow_user.blank?

      channel = user.channels_db.find_by_name("旧版关注对象")
      if channel.blank?
        channel = user.channels_db.create(:name=>"旧版关注对象")
      end

      cc = ChannelContact.find_by_channel_id_and_contact_id(channel.id,contact.id)
      if cc.blank?
        ChannelContact.create(:contact=>contact,:channel=>channel)
      end

    end
  rescue Exception => ex
    puts ex.backtrace.join("\n")
    puts ex.message
    raise ex
  end


end