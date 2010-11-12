require 'test_helper'

class TextEntryTest < ActiveSupport::TestCase

  test "判断文本资源的段落数，按照回车换行分" do
    # 用户
    lifei = users(:lifei)
    # 创建一个文本资源
    entry = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"测试专用文章",:content=>"哈哈"}})
    entry.user = lifei
    entry.save
    text_entry = entry.resource
    # 断言
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\r\n")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"\r\nhaha")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\r\n\r\n")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\r\n\r\n好iahia")
    assert_equal 2, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\r\n哈哈")
    assert_equal 2, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"\r\nhaha\r\n哈\\r\\n哈\r\n")
    assert_equal 2, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\n")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"\nhaha")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\n\n")
    assert_equal 1, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\n\n好iahia")
    assert_equal 2, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"haha\n哈哈")
    assert_equal 2, text_entry.paragraph_count
    # 修改文章内容,再次断言
    text_entry.update_attributes!(:content=>"\nhaha\n哈\\n哈\n")
    assert_equal 2, text_entry.paragraph_count
  end

  test "返回文本资源的所有段落，按照回车换行分" do
    # 用户
    lifei = users(:lifei)
    content = "\n\n哈哈\n呵呵\r\n   \n嘿嘿\n"
    # 创建一个文本资源
    entry = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"测试专用文章",:content=>content}})
    entry.user = lifei
    entry.save
    text_entry = entry.resource
    # 断言
    assert_equal 3, text_entry.paragraph_count
    assert text_entry.paragraphs.include?("哈哈")
    assert text_entry.paragraphs.include?("呵呵")
    assert text_entry.paragraphs.include?("嘿嘿")
    assert "哈哈", text_entry.paragraph_of(1)
    assert "呵呵", text_entry.paragraph_of(2)
    assert "嘿嘿", text_entry.paragraph_of(3)
  end

  test "返回文本资源的所有段落，按照空行分隔" do
    # 用户
    lifei = users(:lifei)
    content = "今天天气很好，\n  挺风和日丽的。\n \t　\n\n \t　\n我们今天下午没课，\n这确实挺爽的。\n\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？"
    entry = Entry.new(:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"测试专用文章",:content=>content}})
    entry.user = lifei
    entry.save
    text_entry = entry.resource
    # 断言
    assert_equal 3, text_entry.part_count
    assert text_entry.parts.include?("今天天气很好，\n  挺风和日丽的。\n \t　\n\n \t　\n")
    assert text_entry.parts.include?("我们今天下午没课，\n这确实挺爽的。\n\n")
    assert text_entry.parts.include?("我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？")
    assert "今天天气很好，\n  挺风和日丽的。\n \t　\n\n \t　\n", text_entry.part_of(1)
    assert "我们今天下午没课，\n这确实挺爽的。\n\n", text_entry.part_of(2)
    assert "我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？", text_entry.part_of(3)
    # \r\n版本
    text_entry.content = "今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？"
    text_entry.save!
    # 断言
    assert_equal 3, text_entry.part_count
    assert text_entry.parts.include?("今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n")
    assert text_entry.parts.include?("我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n")
    assert text_entry.parts.include?("我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？")
    assert "今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n", text_entry.part_of(1)
    assert "我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n", text_entry.part_of(2)
    assert "我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？", text_entry.part_of(3)
    # 文章开始没有 "\r\n\r\n"
    text_entry.content = "今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？"
    text_entry.save!
    # 断言
    assert_equal 3, text_entry.part_count
    assert text_entry.parts.include?("今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n")
    assert text_entry.parts.include?("我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n")
    assert text_entry.parts.include?("我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？")
    assert "今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n", text_entry.part_of(1)
    assert "我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n", text_entry.part_of(2)
    assert "我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？", text_entry.part_of(3)
  end

  #  test "按段落把一个文本资源拆成多个资源" do
  #    # 资源
  #    entry_1 = resource_entries(:entry_1)
  #    entry_2 = resource_entries(:entry_2)
  #    entry_3 = resource_entries(:entry_3)
  #    entry_5 = resource_entries(:entry_5)
  #    entry_6 = resource_entries(:entry_6)
  #    entry_7 = resource_entries(:entry_7)
  #    # 资源容器一
  #    lifei_notebook = notebooks(:lifei_notebook)
  #    lifei_notebook.quotings.all.each {|quoting| quoting.insert_resource_elem_to_structure_map}
  #    assert_equal [entry_1,entry_2,entry_3],lifei_notebook.order_resources
  #    # 资源容器二
  #    chengliwen_notebook = notebooks(:chengliwen_notebook_1)
  #    chengliwen_notebook.quotings.all.each {|quoting| quoting.insert_resource_elem_to_structure_map}
  #    assert_equal [entry_5,entry_6,entry_7],chengliwen_notebook.order_resources
  #    # 用户
  #    lifei = users(:lifei)
  #    content = "\r\n今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？\n\n最后一段"
  #    text_entry = TextEntry.create!(:user=>lifei,:title=>"测试专用文章",:content=>content)
  #
  #    lifei_notebook.insert_resource(text_entry.resource_entry,:before=>entry_2)
  #    lifei_notebook.reload
  #    assert_equal [entry_1,text_entry.resource_entry,entry_2,entry_3], lifei_notebook.order_resources
  #
  #    chengliwen_notebook.insert_resource(text_entry.resource_entry,:before=>entry_5)
  #    chengliwen_notebook.reload
  #    assert_equal [text_entry.resource_entry,entry_5,entry_6,entry_7], chengliwen_notebook.order_resources
  #    # 从第二段拆分 text_entry(4段)，拆分后分成三部分，2之前一部分，2之后一部分，2是一部分
  #    # 然后调整quoting中的资源顺序，拆分出来的三部分替换text_entry原来所在的位置，其他的资源顺序 做相应的调整
  #    text_entries = text_entry.part_split(2)
  #    assert_equal 3, text_entries.count
  #    assert_equal "\r\n今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n", text_entries[0].content
  #    assert_equal "我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n", text_entries[1].content
  #    assert_equal "我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？\n\n最后一段", text_entries[2].content
  #    resource_entries = text_entries.collect do |entry|
  #      entry.resource_entry
  #    end
  #    lifei_notebook.reload
  #    assert_equal [entry_1,resource_entries[0],resource_entries[1],resource_entries[2],entry_2,entry_3], lifei_notebook.order_resources
  #    chengliwen_notebook.reload
  #    assert_equal [resource_entries[0],resource_entries[1],resource_entries[2],entry_5,entry_6,entry_7], chengliwen_notebook.order_resources
  #    # 把text_entry，从第一段进行拆分，拆分后textentry是两部分，第一段是一部分，剩余的是第二部分
  #    # quoting中的资源顺序调整同上
  #    text_entries = text_entry.part_split(1)
  #    assert_equal 2, text_entries.count
  #    assert_equal "\r\n今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n", text_entries[0].content
  #    assert_equal "我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？\n\n最后一段", text_entries[1].content
  #    # 把text_entry，从最后一段进行拆分，拆分后textentry是两部分，第二段是最后部分，在此之前的是第一部分
  #    # quoting中的资源顺序调整同上
  #    text_entries = text_entry.part_split(4)
  #    assert_equal 2, text_entries.count
  #    assert_equal "\r\n今天天气很好，\r\n  挺风和日丽的。\r\n \t　\r\n\r\n \t　\r\n我们今天下午没课，\r\n这确实挺爽的。\r\n\r\n我一大中午早早的跑去上自习，这么大的宿舍楼，它咋就没人呢？\n\n", text_entries[0].content
  #    assert_equal "最后一段", text_entries[1].content
  #  end

end
