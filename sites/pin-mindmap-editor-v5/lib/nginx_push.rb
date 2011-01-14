
class NginxPush
  if RAILS_ENV == "production"
    MINDMAP_PUSH_URL = "http://mindmap-editor.mindpin.com/mindmaps/push"
  else
    MINDMAP_PUSH_URL = "http://dev.mindmap-editor.mindpin.com/mindmaps/push"
  end
  def self.mindmap_operation_push(mindmap_id,data_hash)
    url_str = URI.parse(MINDMAP_PUSH_URL)
    site = Net::HTTP.new(url_str.host, url_str.port)
    site.open_timeout = 20
    site.read_timeout = 20
    path = "#{url_str.path}?channel=mindmap_#{mindmap_id}"
    site.request_post(path,data_hash.to_json)
  end
  
end
