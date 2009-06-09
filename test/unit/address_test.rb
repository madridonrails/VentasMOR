require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < Test::Unit::TestCase
  fixtures :addresses, :accounts, :users

def test_invalid_with_empty_attributes 
    address = Address.new 
    assert !address.valid? 
    assert !address.errors.invalid?(:country_id) 
    assert !address.errors.invalid?(:addressable_id)
    assert !address.errors.invalid?(:addressable_type)    
end 
def test_valid_address
    address_test = addresses(:address_1)
    address = Address.new(:country_id => address_test.country_id, :addressable_id=> address_test.addressable_id, :addressable_type=> address_test.addressable_type)
    assert address.valid?
    assert address.save
end
end
