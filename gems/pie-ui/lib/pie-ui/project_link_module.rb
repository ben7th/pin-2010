module PieUi
  module ProjectLinkModule
    
    MINDPIN_URLS = {
      "production"=>{
        "user_auth"               =>  "http://www.mindpin.com/",
        "pin-user-auth"           =>  "http://www.mindpin.com/",
        "ui"                      =>  "http://ui.mindpin.com/",
        "pin-mindmap-editor"      =>  "http://mindmap-editor.mindpin.com/",
        "pin-mindmap-image-cache" =>  "http://mindmap-image-cache.mindpin.com/",
        "pin-daotu"               =>  "http://tu.mindpin.com/",
        "pin-schedule"            =>  "http://schedule.mindpin.com/"
      },
      "development"=>{
        "user_auth"               =>  "http://dev.www.mindpin.com/",
        "pin-user-auth"           =>  "http://dev.www.mindpin.com/",
        "ui"                      =>  "http://dev.ui.mindpin.com/",
        "pin-mindmap-editor"      =>  "http://dev.mindmap-editor.mindpin.com/",
        "pin-mindmap-image-cache" =>  "http://dev.mindmap-image-cache.mindpin.com/",
        "pin-daotu"               =>  "http://dev.tu.mindpin.com/",
        "pin-schedule"            =>  "http://dev.schedule.mindpin.com/"
      },
      "test"=>{
        "user_auth"               =>  "http://dev.www.mindpin.com/",
        "pin-user-auth"           =>  "http://dev.www.mindpin.com/",
        "ui"                      =>  "http://dev.ui.mindpin.com/",
        "pin-mindmap-editor"      =>  "http://dev.mindmap-editor.mindpin.com/",
        "pin-mindmap-image-cache" =>  "http://dev.mindmap-image-cache.mindpin.com/",
        "pin-daotu"               =>  "http://dev.tu.mindpin.com/",
        "pin-schedule"            =>  "http://dev.schedule.mindpin.com/"
      }
    }

    def find_site_url_by_name(site_name)
      site_url = MINDPIN_URLS[Rails.env][site_name]
      raise "找不到 site_name 为 #{site_name} 的配置" if site_url.blank?
      site_url
    end

    def pin_url_for(site_name, path = "")
      File.join(find_site_url_by_name(site_name), path)
    end

  end
end