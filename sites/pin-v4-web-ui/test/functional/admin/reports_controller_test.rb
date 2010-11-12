require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase

  test "管理员处理举报信息" do
    clear_model(Report)
    admin = users(:admin)
    lifei = users(:lifei)
    session[:user_id] = admin.id
    entry_1 = entries(:entry_1)
    report_1 = Report.create(:reportable=>entry_1,:creator=>lifei,:content=>"我觉得这玩意不顺眼",:reason=>Report::POLITICAL)
    assert_equal Report.count,1
    
    # 忽略这个不良信息报告
    put :update,:id=>report_1.id,:forbidden=>false
    report_1.reload
    entry_1.reload
    assert_equal report_1.handled,true
    assert_equal entry_1.forbidden,nil

    entry_2 = entries(:entry_2)
    report_2 = Report.create(:reportable=>entry_2,:creator=>lifei,:content=>"我觉得这玩意不顺眼",:reason=>Report::POLITICAL)
    assert_equal Report.count,2

    # 禁用这个entry
    put :update,:id=>report_2.id,:forbidden=>true
    report_2.reload
    entry_2.reload
    assert_equal report_2.handled,true
    assert_equal entry_2.forbidden,true
  end
end
