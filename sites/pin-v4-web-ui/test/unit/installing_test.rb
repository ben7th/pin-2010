require 'test_helper'

class InstallingTest < ActiveSupport::TestCase
  test "安装应用" do
    mindmap_editor = "mindmap_editor"
    callback_url = ""
    title = "思维导图"
    developer = "MindPin Team"
    callback_url = "http://192.168.1.8:9528"
    port = "80"
    subject = "思维导图的说明"

    app = App.create!(:name=>mindmap_editor,
      :title=>title,:developer=>developer,
      :callback_url=>callback_url,
      :port=>port,
      :subject=>subject
    )
    lifei = users(:lifei)
    assert_difference("lifei.apps.count",1) do
      Installing.create(:app=>app,:user=>lifei)
      Installing.create(:app=>app,:user=>lifei)
    end
  end
end