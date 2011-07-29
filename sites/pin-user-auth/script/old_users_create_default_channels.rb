

user_ids = User.find_by_sql(%`
    select users.id from users order by users.id asc
  `).map{|u|u.id}

count = user_ids.length

begin
  user_ids.each_with_index do |id,index|
    ActiveRecord::Base.transaction do
      p "正在处理 user_#{id}  #{index+1}/#{count}"

      user = User.find_by_id(id)
      next if user.blank?

      user.create_default_channels

      contacts = user.contacts
      next if contacts.blank?

      channel = Channel.find_or_create_by_creator_id_and_name(user.id,"旧版关注对象")
      
      contacts.each do |contact|
        next if contact.user.blank?
        next if contact.follow_user.blank?

        cc = ChannelContact.find_by_channel_id_and_contact_id(channel.id,contact.id)
        if cc.blank?
          ChannelContact.create(:contact=>contact,:channel=>channel)
        end
      end


    end
  end
rescue Exception => ex
  puts ex.backtrace.join("\n")
  puts ex.message
  raise ex
end

