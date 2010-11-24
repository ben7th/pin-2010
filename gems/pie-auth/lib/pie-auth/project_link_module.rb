module ProjectLinkModule
  URLS = {
    "production"=>{
      "user_auth"               =>  "http://www.mindpin.com/",
      "pin-user-auth"           =>  "http://www.mindpin.com/",
      "discuss"                 =>  "http://discuss.mindpin.com/",
      "pin-discuss"             =>  "http://discuss.mindpin.com/",
      "pin-workspace"           =>  "http://workspace.mindpin.com/",
      "ui"                      =>  "http://ui.mindpin.com/",
      "pin-bugs"                =>  "http://bugs.mindpin.com/",
      "pin-app-adapter"         =>  "http://app-adapter.mindpin.com/",
      "pin-share"               =>  "http://share.mindpin.com/",
      "pin-mindmap-editor"      =>  "http://mindmap-editor.mindpin.com/",
      "pin-mindmap-image-cache" =>  "http://mindmap-image-cache.mindpin.com/",
      "pin-macro"               =>  "http://macro.mindpin.com/",
      "pin-website"             =>  "http://website.mindpin.com/"
    },
    "development"=>{
      "user_auth"               =>  "http://dev.www.mindpin.com/",
      "pin-user-auth"           =>  "http://dev.www.mindpin.com/",
      "discuss"                 =>  "http://dev.discuss.mindpin.com/",
      "pin-discuss"             =>  "http://dev.discuss.mindpin.com/",
      "pin-workspace"           =>  "http://dev.workspace.mindpin.com/",
      "ui"                      =>  "http://dev.ui.mindpin.com/",
      "pin-bugs"                =>  "http://dev.bugs.mindpin.com/",
      "pin-app-adapter"         =>  "http://dev.app-adapter.mindpin.com/",
      "pin-share"               =>  "http://dev.share.mindpin.com/",
      "pin-mindmap-editor"      =>  "http://dev.mindmap-editor.mindpin.com/",
      "pin-mindmap-image-cache" =>  "http://dev.mindmap-image-cache.mindpin.com/",
      "pin-macro"               =>  "http://dev.macro.mindpin.com/",
      "pin-website"             =>  "http://dev.website.mindpin.com/"
    },
    "test"=>{
      "user_auth"=>"http://dev.2010.mindpin.com/",
      "pin-user-auth"=>"http://dev.2010.mindpin.com/",
      "discuss"=>"http://dev.discuss.2010.mindpin.com/",
      "pin-discuss"=>"http://dev.discuss.2010.mindpin.com/",
      "pin-workspace"=>"http://dev.workspace.2010.mindpin.com/",
      "ui"=>"http://dev.ui.mindpin.com/",
      "pin-bugs"=>"http://dev.bugs.2010.mindpin.com/",
      "pin-app-adapter"=>"http://dev.app-adapter.2010.mindpin.com/",
      "pin-share"=>"http://dev.share.2010.mindpin.com/",
      "pin-mindmap-editor"=>"http://dev.mindmap-editor.2010.mindpin.com/",
      "pin-mindmap-image-cache"=>"http://dev.mindmap-image-cache.2010.mindpin.com/",
      "pin-macro"=>"http://dev.macro.2010.mindpin.com/",
      "pin-website"=>"http://dev.website.2010.mindpin.com/"
      }
  }
  
  def pin_url_for(project_name,path=nil)
    path ||= ""
    return File.join(find_site_by_name(project_name),path)
  end

  def find_site_by_name(project_name)
    site = URLS[RAILS_ENV][project_name]
    if site.blank?
      raise "没有 project_name 是 #{project_name} 的配置 "
    end
    site
  end

end