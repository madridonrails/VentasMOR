require File.dirname(__FILE__) + '/../test_helper'
require 'public_controller'

class PublicControllerTest < ActionController::TestCase
  fixtures :users, :accounts
  
  def setup
    @controller = PublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
   
    @request.host = "foo.#{DOMAIN_NAME}"
  end
  
  def test_login
    foo = users(:foo)
    post :login, :login => foo.email, :password => "test"
    assert_response :success
  end
  
  def test_error_in_login
    foo = users(:foo)
    post :login, :login => foo.email, :password => '_est'
    assert_template 'login'    
  end
end
