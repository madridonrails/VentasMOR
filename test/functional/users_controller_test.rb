require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

class UsersControllerTest < ActionController::TestCase
  fixtures :users, :accounts
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end
  
  def test_create
    post :create, :user => {:name =>'Foo'}
    assert_response :success
    assert_template 'new'
  end
end
