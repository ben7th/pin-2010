require 'test_helper'

class ImageMarksControllerTest < ActionController::TestCase

  test "创建图片标注" do
    lifei = users(:lifei)
    assert_difference(["Entry.count","FileEntry.count"],1) do
      Entry.create!(:user=>lifei,:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
    end
    session[:user_id] = lifei.id
    entry = Entry.last
    assert_difference(["entry.image_marks.count","Remark::ImageMark.count"],1) do
      post :create,:image_mark=>{:content=>"这个人是谁",:left=>100,:top=>100.0,:width=>20,:height=>30},:entry_id=>entry.id
    end
    image_mark = Remark::ImageMark.last
    assert_equal image_mark.content,"这个人是谁"
  end
end