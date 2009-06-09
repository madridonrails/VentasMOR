require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < Test::Unit::TestCase
  fixtures :accounts,:users

  def test_invalid_with_empty_attributes
    account = Account.new
    assert !account.valid?
    assert account.errors.invalid?(:name)
    assert account.errors.invalid?(:short_name)
  end
  
  def test_unique_short_name
    pepe = accounts(:pepe)
    account = Account.new(:short_name => pepe.short_name,
      :name => pepe.name,
      :blocked => 0)
    assert !account.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], account.errors.on(:short_name)
  end
  
  def test_exclusion_of_reserved_subdomains
    Config.reserved_subdomains << "www"
    account = Account.new(:short_name => "www",
      :name => "www",
      :blocked => 0)
    assert !account.save
    assert_equal 'ésta es una dirección reservada', account.errors.on(:short_name)    
  end
  
  def test_format_of_short_name
    ok = %w{ samuel fernando maria74 yolanda-1 }
    bad = %w{ Samuel fer_nando 74maria "yol anda" }
    
    ok.each do |name|
      account = Account.new(:short_name => name,
      :name => name,
      :blocked => 0)
      assert account.valid?, account.errors.full_messages
    end
    
    bad.each do |name|
      account = Account.new(:short_name => name,
      :name => name,
      :blocked => 0)
      assert !account.valid?, "saving #{name}"
    end
  end
end
