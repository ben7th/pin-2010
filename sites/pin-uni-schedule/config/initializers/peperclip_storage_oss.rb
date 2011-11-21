module Paperclip
  module Storage
    module Oss
      def self.extended base
        p "oss self.extended"
      end

      def exists?(style_name = default_style)
        !original_filename.blank?
      end

      def to_file style_name = default_style
        p "oss to_file #{style_name}"
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          log("saving #{path(style)}")
          begin
            OssManager.upload_file(file,path(style),content_type)
          rescue ::Oss::NoSuchBucketError => ex
            OssManager.create_bucket
            OssManager.set_bucket_to_public
            retry
          rescue ::Oss::ResponseError => ex
            raise
          end

        end
        
        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          log("deleting #{path}")
          begin
            OssManager.delete_file(path)
          rescue ::Oss::ResponseError => ex
            # 忽略吧...
          end
        end
        @queued_for_delete = []
      end
    end

  end
end
