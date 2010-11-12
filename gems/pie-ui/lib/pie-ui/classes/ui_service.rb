class UiService

  class << self

    def asset_id
      # 获取用于区分静态文件缓存的asset_id
      # 暂时先硬编码实现，如果将来需要分布在不同的服务器上，再对这个方法进行修改
      case RAILS_ENV
      when 'development'
        randstr #开发环境的话 不去缓存
      when 'production'
        last_modified_file_id('/web/2010/pin-v4-web-ui/')
      end
    end

    def env_asset_id
      ENV['RAILS_ASSET_ID']
    end

    def last_modified_file_id(project_dir)
      t1 = Time.now
      repo = Grit::Repo.new(project_dir)
      js  = repo.log('master', 'public/javascripts', :max_count => 1).first
      css = repo.log('master', 'public/stylesheets', :max_count => 1).first
      t2 = Time.now
      RAILS_DEFAULT_LOGGER.info "获取 asset_id 耗时 #{(t2 - t1)*1000}ms"
      js.committed_date > css.committed_date ? js.id : css.id
    end

    def site
      pin_url_for('ui')
    end

    def css_files
      ['common','ui'].map{|x| css_path(x)}
    end

    def css_path(bundle_name)
      File.join site,"stylesheets/bundle_#{bundle_name}.css?#{env_asset_id}"
    end

    def theme_css_file
      File.join site,"stylesheets/themes/black.css?#{env_asset_id}"
    end
  end

  class << self
    def js_lib_files
      [
        File.join(site,"javascripts/dev/prototype/protoaculous.1.8.3.min.js?#{env_asset_id}"),
        File.join(site,"javascripts/dev/jquery/jquery-1.4.2.min.noconflict.js?#{env_asset_id}")
      ]
    end

    def js_files
      ['common','mindpin'].map{|x| js_path(x)}
    end

    def js_path(bundle_name)
      File.join site,"javascripts/bundle_#{bundle_name}.js?#{env_asset_id}"
    end
  end

end
