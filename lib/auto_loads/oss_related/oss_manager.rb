class OssManager
  YML_FILE_PATH = File.join(File.dirname(File.expand_path(__FILE__)),"oss.yml")

  CONFIG = YAML.load_file(YML_FILE_PATH)[Rails.env]
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

  def self.get_file(save_path)
    OSS.get_file(CONFIG["bucket"],save_path)
  end

  def self.get_file_body(save_path)
    OSS.get_file_body(CONFIG["bucket"],save_path)
  end

  def self.get_file_meta(save_path)
    OSS.get_file_meta(CONFIG["bucket"],save_path)
  end

  def self.file_exists?(save_path)
    OSS.file_exists?(CONFIG["bucket"],save_path)
  end

end
