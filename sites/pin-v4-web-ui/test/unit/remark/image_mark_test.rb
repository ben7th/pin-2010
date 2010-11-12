require 'test_helper'

class Remark::ImageMarkTest < ActiveSupport::TestCase
  test "创建一个图片标注" do
    lifei = users(:lifei)
    assert_difference(["Entry.count","FileEntry.count"],1) do
      Entry.create!(:user=>lifei,:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
    end
    entry = Entry.last
    assert_difference(["entry.image_marks.count","Remark::ImageMark.count"],1) do
      entry.image_marks.create!(:creator=>lifei,:content=>"这个人是谁",:left=>100,:top=>100.0,:width=>20,:height=>30)
    end
    image_mark = Remark::ImageMark.last
    assert_equal image_mark.content,"这个人是谁"
  end
end