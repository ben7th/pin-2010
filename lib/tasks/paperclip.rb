module Paperclip
  module Task
    def self.obtain_class
      class_name = ENV['CLASS'] || ENV['class']
      raise "Must specify CLASS" unless class_name
      class_name
    end

    def self.obtain_attachments(klass)
      klass = Paperclip.class_for(klass.to_s)
      name = ENV['ATTACHMENT'] || ENV['attachment']
      raise "Class #{klass.name} has no attachments specified" unless klass.respond_to?(:attachment_definitions)
      if !name.blank? && klass.attachment_definitions.keys.include?(name)
        [ name ]
      else
        klass.attachment_definitions.keys
      end
    end
  end

  module MindpinTask

    def self.lock_timestamps
      klass = Paperclip::Task.obtain_class
      klass_object = Paperclip.class_for(klass)
      def klass_object.record_timestamps
        false
      end

      return klass
    end

    def self.refresh_fingerprint(instance, name)
      if instance.respond_to?("#{name}_fingerprint")
        attachment = instance.send(name)
        md5 = attachment.generate_fingerprint(attachment.to_file(:original))
        instance.send("#{name}_fingerprint=",md5)
      end
    end

    def self.refresh_size_meta(instance, name)
      if instance.respond_to?("#{name}_meta=")
        meta = {}
        instance.send(name).options.styles.map(&:first).push(:original).each do |style|
          file = instance.send(name).to_file(style)
          begin
            geo = Paperclip::Geometry.from_file file
            meta[style] = {:width => geo.width.to_i, :height => geo.height.to_i, :size => File.size(file) }
          rescue NotIdentifiedByImageMagickError => e
            meta[style] = {}
          end
        end
        meta_str = ActiveSupport::Base64.encode64(Marshal.dump(meta))
        instance.send("#{name}_meta=",meta_str)
      end
    end

  end
end

namespace :paperclip do
  desc "Refreshes both metadata and thumbnails."
  # task :refresh => ["paperclip:refresh:metadata", "paperclip:refresh:thumbnails"]
  task :refresh => ["paperclip:refresh:thumbnails", "paperclip:refresh:metadata"]

  namespace :refresh do
    desc "Regenerates thumbnails for a given CLASS (and optional ATTACHMENT and STYLES splitted by comma)."
    task :thumbnails => :environment do
      errors = []
      klass = Paperclip::Task.obtain_class
      names = Paperclip::Task.obtain_attachments(klass)
      styles = (ENV['STYLES'] || ENV['styles'] || '').split(',').map(&:to_sym)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          instance.send(name).reprocess!(*styles)
          puts instance.id # 处理完一条记录输出一次
          errors << [instance.id, instance.errors] unless instance.errors.blank?
        end
      end
      errors.each{|e| puts "#{e.first}: #{e.last.full_messages.inspect}" }
    end

    desc "Regenerates content_type/size metadata for a given CLASS (and optional ATTACHMENT)."
    task :metadata => :environment do

      # ----------------
      # 保证 save 不会修改 updated_at 字段
      # by lifei
      klass = Paperclip::MindpinTask.lock_timestamps
      # ---------------

      names = Paperclip::Task.obtain_attachments(klass)
      names.each do |name|
        Paperclip.each_instance_with_attachment(klass, name) do |instance|
          if file = instance.send(name).to_file(:original)
            instance.send("#{name}_file_name=", instance.send("#{name}_file_name").strip)
            instance.send("#{name}_content_type=", file.content_type.strip)
            instance.send("#{name}_file_size=", file.size) if instance.respond_to?("#{name}_file_size")

            # -----------------------------------
            # 增加 fingerprint 和 meta 字段的 更新
            # by lifei
            Paperclip::MindpinTask.refresh_fingerprint(instance, name)
            Paperclip::MindpinTask.refresh_size_meta(instance, name)
            puts instance.id # 处理完一条记录输出一次
            # -----------------------------
            
            if Rails.version >= "3.0.0"
              instance.save(:validate => false)
            else
              instance.save(false)
            end
          else
            true
          end
        end
      end
    end

    desc "Regenerates missing thumbnail styles for all classes using Paperclip."
    task :missing_styles => :environment do
      # Force loading all model classes to never miss any has_attached_file declaration:
      Dir[Rails.root + 'app/models/**/*.rb'].each { |path| load path }
      Paperclip.missing_attachments_styles.each do |klass, attachment_definitions|
        attachment_definitions.each do |attachment_name, missing_styles|
          puts "Regenerating #{klass} -> #{attachment_name} -> #{missing_styles.inspect}"
          ENV['CLASS'] = klass.to_s
          ENV['ATTACHMENT'] = attachment_name.to_s
          ENV['STYLES'] = missing_styles.join(',')
          Rake::Task['paperclip:refresh:thumbnails'].execute
        end
      end
      Paperclip.save_current_attachments_styles!
    end
  end

  desc "Cleans out invalid attachments. Useful after you've added new validations."
  task :clean => :environment do
    klass = Paperclip::Task.obtain_class
    names = Paperclip::Task.obtain_attachments(klass)
    names.each do |name|
      Paperclip.each_instance_with_attachment(klass, name) do |instance|
        unless instance.valid?
          attributes = %w(file_size file_name content_type).map{ |suffix| "#{name}_#{suffix}".to_sym }
          if attributes.any?{ |attribute| instance.errors[attribute].present? }
            instance.send("#{name}=", nil)
            if Rails.version >= "3.0.0"
              instance.save(:validate => false)
            else
              instance.save(false)
            end
          end
        end
      end
    end
  end

  # 以下是自己增加的 oss 专用的 rake 任务，由于没有考虑 fingerprint 和 meta 暂时不建议使用
#  desc "oss 专用 refresh"
#  task :oss_refresh => ["paperclip:oss_refresh:oss_metadata", "paperclip:oss_refresh:oss_thumbnails"]
#  namespace :oss_refresh do
#    desc "oss 专用  thumbnails"
#    task :oss_thumbnails => :environment do
#      errors = []
#      klass = Paperclip::Task.obtain_class
#      names = Paperclip::Task.obtain_attachments(klass)
#      styles = (ENV['STYLES'] || ENV['styles'] || '').split(',').map(&:to_sym)
#
#      names.each do |name|
#        Paperclip.each_instance_with_attachment(klass, name) do |instance|
#          process_styles = instance.send(name).options.styles.map(&:first).select do |s|
#            (styles.empty? || styles.include?(s)) &&
#              !instance.send(name).exists?(s)
#          end
#          instance.send(name).reprocess!(*process_styles)
#          errors << [instance.id, instance.errors] unless instance.errors.blank?
#        end
#      end
#      errors.each{|e| puts "#{e.first}: #{e.last.full_messages.inspect}" }
#    end
#
#    desc "oss 专用 metadata"
#    task :oss_metadata => :environment do
#      klass = Paperclip::Task.obtain_class
#      names = Paperclip::Task.obtain_attachments(klass)
#      names.each do |name|
#        Paperclip.each_instance_with_attachment(klass, name) do |instance|
#          meta = instance.send(name).meta(:original)
#          if !meta.blank?
#            instance.send("#{name}_file_name=", instance.send("#{name}_file_name").strip)
#            instance.send("#{name}_content_type=", meta[:content_type].strip)
#            instance.send("#{name}_file_size=", meta[:content_length]) if instance.respond_to?("#{name}_file_size")
#            if Rails.version >= "3.0.0"
#              instance.save(:validate => false)
#            else
#              instance.save(false)
#            end
#          else
#            true
#          end
#        end
#      end
#    end
#
#    desc "oss 专用 missing_styles"
#    task :missing_styles => :environment do
#      Dir[Rails.root + 'app/models/**/*.rb'].each { |path| load path }
#      Paperclip.missing_attachments_styles.each do |klass, attachment_definitions|
#        attachment_definitions.each do |attachment_name, missing_styles|
#          puts "Regenerating #{klass} -> #{attachment_name} -> #{missing_styles.inspect}"
#          ENV['CLASS'] = klass.to_s
#          ENV['ATTACHMENT'] = attachment_name.to_s
#          ENV['STYLES'] = missing_styles.join(',')
#          Rake::Task['paperclip:oss_refresh:oss_thumbnails'].execute
#        end
#      end
#      Paperclip.save_current_attachments_styles!
#    end
#  end
end
