class OssManager
  CONFIG = YAML.load_file("#{RAILS_ROOT}/config/oss.yml")[RAILS_ENV]
  OSS = Oss.new(CONFIG["access_key_id"],CONFIG["secret_access_key"])
  
  def self.create_bucket
    OSS.create_bucket(CONFIG["bucket"])
  end

  def self.set_bucket_to_public
    OSS.set_bucket_acl(CONFIG["bucket"], "public-read")
  end

  def self.upload_file(file, save_path, content_type)
    OSS.upload_file(CONFIG["bucket"], file, save_path, content_type)
  end

  def self.delete_file(save_path)
    OSS.delete_file(CONFIG["bucket"], save_path)
  end

end
