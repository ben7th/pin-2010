ActiveRecord::Base.transaction do
  vvs = ViewpointVote.find(:all,
    :conditions=>"viewpoint_votes.status = '#{ViewpointVote::UP}' ")
  count = vvs.length

  vvs.each_with_index do |v,index|
    p "正在处理 #{index+1}/#{count}"

    next unless v.is_vote_up?


    viewpoint = v.viewpoint
    user = viewpoint.user
    user.add_reputation(10)
  end

end



