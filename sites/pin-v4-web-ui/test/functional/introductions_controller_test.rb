require 'test_helper'

class IntroductionsControllerTest < ActionController::TestCase
  
  test "给网站添加简介" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    web_site = WebSite.create(:domain=>"http://www.williamlong.info/")
    get :new,:web_site_id=>web_site.id
    assert_response :success
    assert_difference("Introduction.count",1) do
      post :create,:web_site_id=>web_site.id,:introduction=>{:content=>"这个测试很简单"}
    end
    introduction = Introduction.last
    assert_equal introduction.content,"这个测试很简单"
    assert_equal introduction.user,lifei
    assert_equal introduction.introductable,web_site

    get :edit,:web_site_id=>web_site.id,:id=>introduction
    assert_response :success
    assert_difference("Introduction.count",1) do
      put :update,:web_site_id=>web_site.id,:id=>introduction,:content=>"很纠结很无奈我也不想说什么了:)"
    end
    introduction = Introduction.last
    assert_equal introduction.content,"很纠结很无奈我也不想说什么了:)"
    assert_equal introduction.user,lifei
    assert_equal introduction.introductable,web_site
  end

  test "分段编辑" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    web_site = WebSite.create(:domain=>"http://www.williamlong.info/")
    content = %~
# 太阳 #
太阳发出了光和热
# 月亮 #
月亮反射了太阳的光芒
# 地球 #
地球是蓝色的
# 火星 #
火星人都很 OUT
    ~
    assert_difference("Introduction.count",1) do
      post :create,:web_site_id=>web_site.id,:introduction=>{:content=>content}
    end
    introduction = Introduction.last
    assert_difference("Introduction.count",1) do
      put :update,:web_site_id=>web_site.id,:id=>introduction,:content=>"地球消失了",:section=>"2"
    end
    introduction = Introduction.last
  end
end
