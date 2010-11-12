require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  test "举报不良信息" do
    entry = entries(:entry_1)
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    get :new,:entry_id=>entry.id
    assert_response :success
    assert_difference("Report.count",1) do
      post :create,:entry_id=>entry.id,:report=>{:reason=>Report::POLITICAL,:content=>"这是一条非常不好的信息"}
    end
    report = Report.last
    assert_equal report.content, "这是一条非常不好的信息"
    assert_equal report.reason, Report::POLITICAL
    assert_equal entry.reports.count,1
    assert entry.reports.include?(report)
    assert_equal report.creator,lifei
    get :index
    assert_response :success
  end
end
