require "test/unit"
require "rack/test"

class RoutesTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Mindpin::Application
  end
  
  def test_login
    login_cookie = "_mindpin_session_devel=BAh7CCIQX2NzcmZfdG9rZW4iMU1Nd2tRc2o5cDk3WVVXVTRqUDVRL1VaOE16N25DNGdkT3JOL1JuQUhHNFE9Ig9zZXNzaW9uX2lkIiVkYmUzMDJmOWY0ZGU0OTU1NDk4NjE4MmE1ZGJlYmVlMiIMdXNlcl9pZGkCDwE%3D--9d66b6a890fd107178781e20be64a5e87b4e6a00"
    
    set_cookie(login_cookie)
    get "/"
    assert last_response.ok?
    assert_equal nil,Nokogiri::HTML(last_response.body).at_css("input#email")
    
    get "/login"
    assert last_response.ok?
    assert_equal nil,Nokogiri::HTML(last_response.body).at_css("input#email")
    
    ["/publics","/favs"].each do |path|
      get path
      assert last_response.ok?
    end
    
    get "/search",:q=>"abc"
    assert last_response.ok?
    
    get "/users/271"
    assert last_response.ok?
    
    get "/mindmaps/cooperates"
    assert last_response.ok?
    
    get "/mindmaps/import"
    assert last_response.ok?
  end
  
  def test_unlogin
    get "/"
    assert last_response.ok?
    assert !Nokogiri::HTML(last_response.body).at_css("input#email").blank?
    
    get "/login"
    assert last_response.ok?
    assert !Nokogiri::HTML(last_response.body).at_css("input#email").blank?
    
    get "/publics"
    assert last_response.ok?
    
    get "/favs"
    follow_redirect!
    assert_equal "http://dev.www.mindpin.com/login",last_request.url
    assert last_response.ok?
    
    get "/search",:q=>"abc"
    assert last_response.ok?
    
    get "/users/271"
    assert last_response.ok?
    
    get "/mindmaps/cooperates"
    follow_redirect!
    assert_equal "http://dev.www.mindpin.com/login",last_request.url
    assert last_response.ok?
    
    get "/mindmaps/import"
    follow_redirect!
    assert_equal "http://dev.www.mindpin.com/login",last_request.url
    assert last_response.ok?
  end
end