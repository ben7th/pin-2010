photos = Photo.find(:all,:select=>"id",:order=>"id asc")
count = photos.length

photos.each_with_index do |p,index|
  p "正在处理 #{index+1}/#{count}"

  photo = Photo.find(p.id)

  [:w500, :w250, :s100, :original].each do |style|

    begin
      path = photo.image.path(style)

      if style != :original && !File.exists?(path)
        photo.image.reprocess!(style)
      end

      file_name         = photo.image_file_name
      file_content_type = photo.image_content_type
      oss_path          = "/photos/images/#{photo.id}/#{style.to_s}/#{file_name}"

      File.open(path,"r") do |file|
        begin
          OssManager.upload_file(file, oss_path, file_content_type)
        rescue ::Oss::NoSuchBucketError => ex
          p "创建 #{OssManager::CONFIG["bucket"]}"
          OssManager.create_bucket
          OssManager.set_bucket_to_public
          retry
        end
      end
    rescue Exception => e
      File.open("/web/2010/logs/upload_photo_image_to_oss.log","a") do  |f|
        f << "photo_id=#{photo.id}, style=#{style}, message=#{e.class}, #{e.message}\n"
      end
    end

  end

end