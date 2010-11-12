require 'test_helper'

class EntryTest < ActiveSupport::TestCase

  test "count_by_user" do
    clear_model(Entry)
    lifei = users(:lifei)
    e_1 = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本1",:content => "文本1内容"}})
    e_1.user = lifei
    e_1.save
    e_2 = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本2",:content => "文本2内容"}})
    e_2.user = lifei
    e_2.save
    e_3 = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本3",:content => "文本3内容"}})
    e_3.user = lifei
    e_3.save
    songliang = users(:songliang)
    e_4 = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本4",:content => "文本4内容"}})
    e_4.user = songliang
    e_4.save
    e_5 = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本5",:content => "文本5内容"}})
    e_5.user = songliang
    e_5.save
    assert_equal Entry.count_by_user(lifei),3
    assert_equal Entry.count_by_user(songliang),2
  end

  test "给 ResourceEntry 增加标签" do
    clear_model(Tag)
    clear_model(Tagging)
    lifei = users(:lifei)
    songliang = users(:songliang)
    re = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本五",:content => "文本五内容"}})
    re.user = lifei
    re.save
    assert_equal "",re.tags_str_of(lifei)

    re.add_tag(lifei,"标签一,标签二")
    assert_equal "标签一,标签二",re.tags_str_of(lifei)
    assert_equal "",re.tags_str_of(songliang)

    re.add_tag(lifei,"标签一")
    assert_equal "标签一,标签二",re.tags_str_of(lifei)
  end

  test "创建文本" do
    lifei = users(:lifei)
    clear_model(Entry,TextEntry)
    assert_difference(["Entry.count","TextEntry.count"],1) do
      entry = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:content => "修改一下创建方式"}})
      entry.user = lifei
      entry.save
    end
    text_entry = TextEntry.last
    assert_equal text_entry.content,"修改一下创建方式"
    assert_difference(["Entry.count","TextEntry.count"],0)  do
      entry = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:content => ""}})
      entry.user = lifei
      entry.save
    end
  end

  test "创建文件" do
    lifei = users(:lifei)
    clear_model(Entry,FileEntry)
    assert_difference(["Entry.count","FileEntry.count"],1) do
      entry = Entry.new(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
      entry.user = lifei
      entry.save
    end
    assert_difference(["Entry.count","FileEntry.count"],0)  do
      entry = Entry.new(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>nil}})
      entry.user = lifei
      entry.save
    end
  end
end
