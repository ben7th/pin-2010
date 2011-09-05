class UiService

  class << self
    def asset_id
      # 获取用于区分静态文件缓存的asset_id
      # 暂时先硬编码实现，如果将来需要分布在不同的服务器上，再对这个方法进行修改
      case RAILS_ENV
      when 'development'
        randstr #开发环境的话 不去缓存
      when 'production'
        last_modified_file_id('/web/2010/pin-2010/')
      end
    end

    def env_asset_id
      ENV['RAILS_ASSET_ID']
    end

    def last_modified_file_id(project_dir)
      t1 = Time.now
      repo = Grit::Repo.new(project_dir)
      js  = repo.log('master', 'sites/pin-v4-web-ui/public/javascripts', :max_count => 1).first
      css = repo.log('master', 'sites/pin-v4-web-ui/public/stylesheets', :max_count => 1).first
      t2 = Time.now
      RAILS_DEFAULT_LOGGER.info "获取 asset_id 耗时 #{(t2 - t1)*1000} s"
      js.committed_date > css.committed_date ? js.id : css.id
    end

    def site
      pin_url_for('ui')
    end
  end

  #-------------------------------------------

  class << self
    def css_files
      case RAILS_ENV
      when 'development'
        return [File.join site,"stylesheets/all.css?#{env_asset_id}"]
      when 'production'
        return [File.join site,"stylesheets/all_packed.css?#{env_asset_id}"]
      end
      
    end
  end

  class << self
    def js_lib_files
      [
        File.join(site,"javascripts/dev/prototype/protoaculous.1.8.3.min.js?#{env_asset_id}"),
        File.join(site,"javascripts/dev/jquery/jquery-1.6.1.min.noconflict.js?#{env_asset_id}")
      ]
    end

    def js_files
      ['base'].map{|x| js_path(x)}
    end

    def js_path(bundle_name)
      File.join site,"javascripts/bundle_#{bundle_name}.js?#{env_asset_id}"
    end
  end

end
