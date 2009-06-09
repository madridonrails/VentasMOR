require File.dirname(__FILE__) + '/../test_helper'

class CustomerTest < Test::Unit::TestCase
  fixtures :addresses, :accounts, :users, :customers

def test_invalid_with_empty_attributes 
    customer = Customer.new 
    assert !customer.valid? 
    assert !customer.errors.invalid?(:account_id) 
    assert customer.errors.invalid?(:name)
    assert !customer.errors.invalid?(:name_normalized)    
    assert !customer.errors.invalid?(:cif )    
end 
def test_valid_customer
    customer_test = customers(:bar)
    customer = Customer.new(:account_id=> customer_test.account_id, :name=> customer_test.name, :name_normalized=> customer_test.name_normalized)
    assert customer.valid?
    assert customer.save
end
end
