prefix_path = File.join(Mindmap::MINDMAP_IMAGE_BASE_PATH,"users")

image_file_paths = Dir["#{prefix_path}/*/*"].select do |path|
  File.file?(path)
end

count = image_file_paths.length
image_file_paths.each_with_index do |path,index|
  begin
    p "处理 #{index+1}/#{count}"

    user_id = path.match(/users\/([0-9]+)\//)[1]
    user = User.find_by_id(user_id)
    next if user.blank?

    image = File.new(path)
    
    ia = ImageAttachment.new(:user=>user,:image=>image)
    if ia.valid?
      ia.save!
    end
  rescue Exception => ex
    p "#{path} 生成缩略图失败"
  end

end