image_attachments = ImageAttachment.find(:all,:select=>"id",:order=>"id asc")
count = image_attachments.length

image_attachments.each_with_index do |ia,index|
  p "正在处理 #{index+1}/#{count}"

  image_attachment = ImageAttachment.find(ia.id)

  [:thumb,:original].each do |style|


    begin
      path = image_attachment.image.path(style)

      file_name         = image_attachment.image_file_name
      file_content_type = image_attachment.image_content_type
      oss_path = "/image_attachments/images/#{image_attachment.id}/#{style.to_s}/#{file_name}"

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
      File.open("/web/2010/logs/upload_image_attachment_image_to_oss.log","a") do  |f|
        f << "image_attachment_id=#{image_attachment.id}, style=#{style}, message=#{e.class}, #{e.message}\n"
      end
    end



  end
end
