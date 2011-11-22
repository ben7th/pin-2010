users = User.find(:all,:select=>"id",:order=>"id asc")
count = users.length

users.each_with_index do |u,index|
  
  p "正在处理 #{index+1}/#{count}"

  user = User.find(u.id)
  next if user.logo_file_name.blank?
  
  [:large, :medium, :normal, :tiny, :mini, :original].each do |style|

    begin
      path = user.logo.path(style)

      if style != :original && !File.exists?(path)
        user.logo.reprocess!(style)
      end

      file_name         = user.logo_file_name
      file_content_type = user.logo_content_type
      oss_path          = "/users/logos/#{user.id}/#{style.to_s}/#{file_name}"

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
      File.open("/web/2010/logs/upload_user_logo_to_oss.log","a") do  |f|
        f << "user_id=#{user.id},style=#{style},message=#{e.message}\n"
      end
    end
  end

end