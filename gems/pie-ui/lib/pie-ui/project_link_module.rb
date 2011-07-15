module ProjectLinkModule
  MINDPIN_URLS = {
    "production"=>{
      "user_auth"               =>  "http://www.mindpin.com/",
      "pin-user-auth"           =>  "http://www.mindpin.com/",
      "ui"                      =>  "http://ui.mindpin.com/",
      "pin-mindmap-editor"      =>  "http://mindmap-editor.mindpin.com/",
      "pin-mindmap-image-cache" =>  "http://mindmap-image-cache.mindpin.com/",
      "pin-daotu"               =>  "http://tu.mindpin.com/"
    },
    "development"=>{
      "user_auth"               =>  "http://dev.www.mindpin.com/",
      "pin-user-auth"           =>  "http://dev.www.mindpin.com/",
      "ui"                      =>  "http://dev.ui.mindpin.com/",
      "pin-mindmap-editor"      =>  "http://dev.mindmap-editor.mindpin.com/",
      "pin-mindmap-image-cache" =>  "http://dev.mindmap-image-cache.mindpin.com/",
      "pin-daotu"               =>  "http://dev.tu.mindpin.com/"
    },
    "test"=>{
      "user_auth"=>"http://dev.2010.mindpin.com/",
      "pin-user-auth"=>"http://dev.2010.mindpin.com/",
      "ui"=>"http://dev.ui.mindpin.com/",
      "pin-mindmap-editor"=>"http://dev.mindmap-editor.2010.mindpin.com/",
      "pin-mindmap-image-cache"=>"http://dev.mindmap-image-cache.2010.mindpin.com/",
      "pin-daotu"               =>  "http://dev.tu.mindpin.com/"
    }
  }
  
  def pin_url_for(project_name,path=nil)
    path ||= ""
    return File.join(find_site_by_name(project_name),path)
  end

  def mindmap_image_cache_url(path=nil,asset_num=nil)
    url = pin_url_for('pin-mindmap-image-cache',path)
    if asset_num.nil?
      return url
    end
    url.sub('mindmap-image-cache',"mindmap-image-cache-#{asset_num}")
  end

  def find_site_by_name(project_name)
    site = MINDPIN_URLS[RAILS_ENV][project_name]
    if site.blank?
      raise "没有 project_name 是 #{project_name} 的配置 "
    end
    site
  end

end