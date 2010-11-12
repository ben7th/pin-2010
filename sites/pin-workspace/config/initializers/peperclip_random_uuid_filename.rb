module Paperclip
  class Attachment
    def assign uploaded_file
      ensure_required_accessors!

      if uploaded_file.is_a?(Paperclip::Attachment)
        uploaded_file = uploaded_file.to_file(:original)
        close_uploaded_file = uploaded_file.respond_to?(:close)
      end

      return nil unless valid_assignment?(uploaded_file)

      uploaded_file.binmode if uploaded_file.respond_to? :binmode
      self.clear

      return nil if uploaded_file.nil?

      @queued_for_write[:original]   = uploaded_file.to_tempfile
      # Paperclip 会把上传文件的原始名称作为文件名
      # 这里修改为 给文件随机命名
      kouzhanming = uploaded_file.original_filename.split(".").last
      base_name = UUIDTools::UUID.random_create.to_s
      # 原始名称存到 title 字段
      @instance.title = uploaded_file.original_filename if @instance.class == FileEntry

      instance_write(:file_name,       "#{base_name}.#{kouzhanming}".strip  )
      instance_write(:content_type,    uploaded_file.content_type.to_s.strip)
      instance_write(:file_size,       uploaded_file.size.to_i)
      instance_write(:updated_at,      Time.now)

      @dirty = true

      post_process

      # Reset the file size if the original file was reprocessed.
      instance_write(:file_size, @queued_for_write[:original].size.to_i)
    ensure
      uploaded_file.close if close_uploaded_file
    end
  end
end