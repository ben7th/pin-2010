require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  
  test "the truth" do
    get "/"
    assert_equal 200, status
    
    lifei = login(:lifei)
    lifei.get("/")
    assert_equal 200, status
  end
  
  def create_user
    User.create(:name=>"lifei",:email=>"lifei@test.com",:password_confirmation=>"123456",:password=>"123456")
  end
end
