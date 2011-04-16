class ChannelContact < UserAuthAbstract
end

ActiveRecord::Base.transaction do
  ccs = ChannelContact.all
  ccs_count = ccs.length
  ccs.each_with_index do |cc,index|
    p "正在处理 #{index+1}/#{ccs_count}"
    next if cc.contact.blank?
    user = cc.contact.follow_user
    channel = cc.channel
    next if user.blank? || channel.blank?

    ChannelUser.create!(:user=>user,:channel=>channel)
  end
end
