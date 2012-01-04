class UiAsset
  class << self
    PRODUCTION_PROJECT_DIR = '/web/2010/pin-2010'

    def asset_id
      # 获取用于区分静态文件缓存的asset_id
      # 暂时先硬编码实现，如果将来需要分布在不同的服务器上，再对这个方法进行修改
      
      randstr if Rails.env.development? # 开发环境的话 不去缓存
      last_modified_file_id(PRODUCTION_PROJECT_DIR) if Rails.env.production?  # 产品环境 读工程更新时间戳
    end

    def last_modified_file_id(project_dir)
      t1 = Time.now
      repo = Grit::Repo.new(project_dir)
      js  = repo.log('master', 'sites/pin-v4-web-ui/public/javascripts', :max_count => 1).first
      css = repo.log('master', 'sites/pin-v4-web-ui/public/stylesheets', :max_count => 1).first
      t2 = Time.now
      Rails.logger.info "获取 asset_id 耗时 #{(t2 - t1)*1000} s"
      js.committed_date > css.committed_date ? js.id : css.id
    end
  end
end
