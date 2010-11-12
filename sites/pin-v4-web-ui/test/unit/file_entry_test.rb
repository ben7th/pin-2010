require 'test_helper'

class FileEntryTest < ActiveSupport::TestCase

  test "判断资源类型" do
    lifei = users(:lifei)
    mp3 = Entry.create!(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1..mp3")}},:user=>lifei).resource
    png = Entry.create!(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}},:user=>lifei).resource
    jpg = Entry.create!(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.JPG")}},:user=>lifei).resource
    bmp = Entry.create!(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.bmp")}},:user=>lifei).resource
    wma = Entry.create!(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.wma")}},:user=>lifei).resource

    assert_equal "WMA", wma.file_type
    assert_equal false, wma.is_image?
    assert_equal true, wma.is_audio?

    assert_equal "BMP", bmp.file_type
    assert_equal true, bmp.is_image?
    assert_equal false, bmp.is_audio?

    assert_equal "JPG", jpg.file_type
    assert_equal true, jpg.is_image?
    assert_equal false, jpg.is_audio?

    assert_equal "PNG", png.file_type
    assert_equal true, png.is_image?
    assert_equal false, png.is_audio?

    assert_equal "MP3", mp3.file_type
    assert_equal false, mp3.is_image?
    assert_equal true, mp3.is_audio?
  end

end
