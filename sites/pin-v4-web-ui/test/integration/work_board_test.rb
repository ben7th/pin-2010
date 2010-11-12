require 'test_helper'

class WorkBoardTest < ActionController::IntegrationTest
  fixtures :all

  test "增加资源,删除资源，显示资源" do
    lifei = users(:lifei)
    wb = get_user_work_board(lifei)
    # 创建一个资源用来引用
    entry = get_a_user_entry(lifei)
    # 增加各种资源
    assert_difference(["wb.entries.count"],1) do
      # 增加文本资源
      hash = {:resource_meta=>{:type=>"TextEntry",:data=>{:title => "文本",:content => "文本内容"}}}
      post "/users/#{lifei.id}/work_board/add",:entry=>hash
    end
    assert_difference("wb.entries.count",1) do
      # 引用资源
      post "/users/#{lifei.id}/work_board/add",:entry=>{:entry_id=>entry.id}
    end

    assert_difference("wb.entries.count",1) do
      # 增加文件资源
      hash = {:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}}}
      multipart_post "/users/#{lifei.id}/work_board/add",:entry=>hash
    end
    # 删除一个资源的引用
    assert_difference("wb.entries.count",-1) do
      assert_difference("Entry.count",0) do
        delete "/users/#{lifei.id}/work_board/remove",:entry_id=>entry.id
      end
    end

    # 显示资源列表
    get "/users/#{lifei.id}/work_board/show"
    assert_response :success
  end

  def get_user_work_board(user)
    assert_difference("WorkBoard.count",1) do
      WorkBoard.create!(:user=>user)
    end
    wb = WorkBoard.last
    assert_equal user.id,wb.user_id
    return wb
  end

  def get_a_user_entry(user)
    assert_difference(["Entry.count","FileEntry.count"],1) do
      entry = Entry.new(:resource_meta=>{:type=>"FileEntry",:data=>{:content=>File.new("#{RAILS_ROOT}/test/upload_files/1.1.PNG")}})
      entry.user = user
      entry.save
    end
    Entry.last
  end

end