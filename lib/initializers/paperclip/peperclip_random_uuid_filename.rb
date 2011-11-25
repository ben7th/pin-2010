module Paperclip
  class Attachment
    def assign uploaded_file
      ensure_required_accessors!

      if uploaded_file.is_a?(Paperclip::Attachment)
        uploaded_filename = uploaded_file.original_filename
        uploaded_file = uploaded_file.to_file(:original)
        close_uploaded_file = uploaded_file.respond_to?(:close)
      else
        instance_write(:uploaded_file, uploaded_file) if uploaded_file
      end

      return nil unless valid_assignment?(uploaded_file)

      uploaded_file.binmode if uploaded_file.respond_to? :binmode
      self.clear

      return nil if uploaded_file.nil?

      uploaded_filename ||= uploaded_file.original_filename
      @queued_for_write[:original]   = to_tempfile(uploaded_file)

      # Paperclip 会把上传文件的原始名称作为文件名
      # 这里修改为 给文件随机命名
      # 以下两行是 lifei 添加的
      # 这段代码放在lib里不起作用，需要放在工程的 initializers 里
      randstr_filename = get_randstr_filename(uploaded_filename)

      # instance_write(:file_name,       uploaded_filename.strip)
      instance_write(:file_name,       randstr_filename) # 这一行修改过，其他代码和原来一样
      instance_write(:content_type,    uploaded_file.content_type.to_s.strip)
      instance_write(:file_size,       uploaded_file.size.to_i)
      instance_write(:fingerprint,     generate_fingerprint(uploaded_file))
      instance_write(:updated_at,      Time.now)

      @dirty = true

      post_process(*@options.only_process) if post_processing

      # Reset the file size if the original file was reprocessed.
      instance_write(:file_size,   @queued_for_write[:original].size.to_i)
      instance_write(:fingerprint, generate_fingerprint(@queued_for_write[:original]))
    ensure
      uploaded_file.close if close_uploaded_file
    end

    # 获取一个随机的文件名
    def get_randstr_filename(uploaded_filename)
      arr = uploaded_filename.split(".")
      ext_name = arr.length > 1 ? arr.last.downcase : ''

      return "#{randstr}.#{ext_name}".strip
    end
  end
end