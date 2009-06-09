require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  include AuthenticatedTestHelper
  fixtures :users, :accounts

  def test_invalid_with_blank_attributes
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:name)
    assert user.errors.invalid?(:password)
    assert user.errors.invalid?(:email)
    assert !user.errors.invalid?(:administrator)
    assert user.errors.invalid?(:salesman)
  end

  def test_invalid_with_used_email
    foo_user = users(:foo)
    user = User.new(:email => foo_user.email)
    user.save
    assert !user.valid?
    assert user.errors.invalid?(:name)
    assert user.errors.invalid?(:password)
    assert !user.errors.invalid?(:email)
  end

  def test_valid_user
    pepe_account = accounts(:pepe)
    pepe_user = users(:pepe)
    user = User.new(:email => pepe_user.email,:account_id=>pepe_account.id)
    assert user.valid?
    assert user.save
  end

end
