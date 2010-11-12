require 'test_helper'

class ReaderControllerTest < ActionController::TestCase

  test "一个人对一条信息查看两次的时候会出项两条reading" do
    lifei = users(:lifei)
    entry = entries(:entry_1)
    session[:user_id] = lifei.id
    session[:next_readable_id] = entry.id
    session[:next_readable_type] = Entry
    assert_difference("Reading.count",1) do
      get :index
      get :index
    end
  end
end
