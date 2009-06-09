require File.dirname(__FILE__) + '/../test_helper'
require 'accounts_controller'

class AccountsControllerTest < ActionController::TestCase
  fixtures :users, :accounts
  
   def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "foo.#{DOMAIN_NAME}"
  end
  
  def test_create_user
    logout
    post :create, :user => {:name =>'Foo'}
    assert_response :success
    assert_template 'new'
  end
  
   private

  def logout
    @request.session[:user] = nil
  end
end
