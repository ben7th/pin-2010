Channel.transaction do
  channels = Channel.all
  count = channels.length
  channels.each_with_index do |channel,index|
    p "正在转换 #{index+1}/#{count}"
    creator = EmailActor.get_user_by_email(channel.creator_email)
    channel.creator_id = creator.id
    channel.save!
  end
end