ActiveRecord::Base.transaction do
  tags = Tag.find(:all,:conditions=>"tags.detail is not null")
  count = tags.count

  tags.each_with_index do |tag,index|
    p "正在转换 #{index+1}/#{count}"
    next if tag.detail.blank?

    tag.tag_detail_revisions.create(:user_id=>1002,:detail=>tag.detail)
  end
end
