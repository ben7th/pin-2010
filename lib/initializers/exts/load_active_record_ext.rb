module PieActiveRecordExt
  
  module SetReadonly
    def self.included(base)
      base.class_eval do
        alias :old_readonly? :readonly?
      end
      base.extend(ClassMethods)
    end

    module ClassMethods
      def set_readonly(boolean)
        return if Rails.env.test?
        define_method "readonly?" do
          return true if boolean
          old_readonly?
        end
      end
    end
  end

  module BuildDatabaseConnection
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      require "yaml"
      SITES_PATH = MindpinRailsLoader::MINDPIN_SITES_PATH

      # options中可以添加 table_name 这个参数  来满足下面这种情况：
      # class name 有时候会和表名取不一样的。应该允许用户指定连接哪一个表
      def build_database_connection(project_name, options={})
        database = YAML.load_file(File.join(SITES_PATH, project_name, 'config/database.yml'))[Rails.env]

        if !Rails.env.test?
          establish_connection(database)
        end

        unless options[:table_name].blank?
          set_table_name(options[:table_name])
        end

      end
    end
  end

  module SaveWithoutTimestamping
    def save_without_timestamping
      class << self
        def record_timestamps; false; end
      end
      save
      class << self
        remove_method :record_timestamps
      end
    end
  end

end

ActiveRecord::Base.send :include, PieActiveRecordExt::SetReadonly
ActiveRecord::Base.send :include, PieActiveRecordExt::BuildDatabaseConnection
ActiveRecord::Base.send :include, PieActiveRecordExt::SaveWithoutTimestamping
