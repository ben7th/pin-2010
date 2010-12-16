require 'em-http'

class NginxPush
  def self.push(channel_id,data)
    EventMachine.run {
      url = "http://dev.mindmap-editor.mindpin.com/mindmaps/push"
      http = EventMachine::HttpRequest.new(url).post :query => {'channel' => channel_id},:body => data

      http.callback {
        p http.response_header.status
        p http.response_header
        p http.response

        EventMachine.stop
      }
    }
  end

end
