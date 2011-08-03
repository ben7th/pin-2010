class ChannelContact < UserAuthAbstract
end

class Contact < UserAuthAbstract
end

ccs_ids = ChannelContact.find_by_sql(%`
    select channel_contacts.id 
    from channel_contacts
    order by channel_contacts.id asc
  `).map{|cc|cc.id}

count = ccs_ids.length

begin
  ccs_ids.each_with_index do |id,index|
    p "正在处理 #{index+1}/#{count}"

    cc = ChannelContact.find_by_id(id)
    contact = Contact.find_by_id(cc.contact_id)
    channel = Channel.find_by_id(cc.channel_id)
    next if contact.blank? || channel.blank?
    creator = channel.creator
    next if creator.blank?
    next if contact.user_id != creator.id
    fu = User.find_by_id(contact.follow_user_id)
    next if fu.blank?

    ChannelUser.create(:channel=>channel,:user=>fu)
  end
rescue Exception => ex
  puts ex.backtrace.join("\n")
  puts ex.message
  raise ex
end
