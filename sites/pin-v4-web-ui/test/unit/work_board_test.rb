require 'test_helper'

class WorkBoardTest < ActiveSupport::TestCase
  test "给 word_board 增加资源，并最多增加20个资源" do
    lifei = users(:lifei)
    wb = get_user_work_board(lifei)
    # 创建一个资源用来引用
    entry = get_a_user_entry(lifei)
    # 增加各种资源
    assert_difference(["wb.entries.count"],1) do
      # 增加文本资源
      assert wb.add(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本",:content => "文本内容"}})
    end
    assert_difference("wb.entries.count",1) do
      # 增加文件资源
      assert wb.add(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
    end
    assert_difference("wb.entries.count",1) do
      # 引用资源
      assert wb.add(:entry_id=>entry.id)
    end
    wb.reload
    # 缓存区只有三个资源，并没有满（可以有20个）
    assert_equal wb.full?,false
    assert_difference("wb.entries.count",17) do
      1.upto(17) do |i|
        assert wb.add(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本#{i}",:content => "文本#{i}内容"}})
      end
    end
    wb.reload
    # 已经成功增加20个
    assert_equal wb.full?,true
    # 缓存区最多20个资源，不能继续增加资源
    assert_difference(["wb.entries.count","Entry.count","TextEntry.count"],0) do
      assert !wb.add(:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本",:content => "文本内容"}})
    end
    wb.reload
    # 从缓存版移除对资源的引用
    entries = wb.entries
    entries.each do |entry|
      wb.reload
      assert_difference("wb.entries.count",-1) do
        assert_difference("Entry.count",0) do
          wb.remove(entry.id)
        end
      end
    end
  end

  def get_a_user_entry(user)
    assert_difference(["Entry.count","FileEntry.count"],1) do
      entry = Entry.new(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
      entry.user = user
      entry.save
    end
    Entry.last
  end

  def get_user_work_board(user)
    assert_difference("WorkBoard.count",1) do
      WorkBoard.create!(:user=>user)
    end
    wb = WorkBoard.last
    assert_equal user.id,wb.user_id
    return wb
  end

  test "同一个entry加入到同一个work_board中去" do
    lifei = users(:lifei)
    wb = get_user_work_board(lifei)
    # 创建一个资源用来引用
    entry = get_a_user_entry(lifei)
    assert_difference(["wb.entries.count","WorkBoardQuoting.count"],1) do
      assert wb.add(:entry_id=>entry.id)
    end
    quoting = WorkBoardQuoting.last
    updated_at = quoting.updated_at
    sleep(1)
    # 经这个entry再次加入到这个workboard中，不再增加quoting，只是更新quoting的时间
    assert_difference(["wb.entries.count","WorkBoardQuoting.count"],0) do
      assert wb.add(:entry_id=>entry.id)
    end
    assert updated_at < quoting.reload.updated_at
  end
end