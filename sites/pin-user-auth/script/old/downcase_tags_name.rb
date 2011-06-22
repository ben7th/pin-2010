ActiveRecord::Base.transaction do
  tags = Tag.all
  count = tags.length

  tags.each_with_index do |tag,index|
    p "正在转换 #{index+1}/#{count}"

    tag.name = tag.name.downcase
    tag.save_without_timestamping
  end
end
