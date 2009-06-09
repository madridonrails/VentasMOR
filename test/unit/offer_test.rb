require File.dirname(__FILE__) + '/../test_helper'

class OfferTest < Test::Unit::TestCase
  
  include AuthenticatedTestHelper
  fixtures :users, :accounts, :offers, :customers

  NEW_OFFER = {:name => 'test'} # e.g. {:name => 'Test', :description => 'Dummy'}
  REQ_ATTR_NAMES = %w(name amount customer_id salesman_id deal_date status_id) # name of fields that must be present, e.g. %(name description)
  
  def test_invalid_with_blank_attributes
    offer = Offer.new
    assert !offer.valid?
    assert !offer.errors.invalid?(:saleman_id)
    assert offer.errors.invalid?(:name)
    assert !offer.errors.invalid?(:name_normalized)
    assert offer.errors.invalid?(:amount)
    assert offer.errors.invalid?(:deal_date)
    assert offer.errors.invalid?(:customer_id)
    assert !offer.errors.invalid?(:description)
    assert offer.errors.invalid?(:status_id)
    assert !offer.errors.invalid?(:weight)
    assert !offer.errors.invalid?(:description_normalized)
    assert !offer.errors.invalid?(:delta)
  end
  
  def test_valid_offer
    new_offer = offers(:foo)
    offer = Offer.new(:name => new_offer.name, :amount => new_offer.amount, :deal_date => new_offer.deal_date, :customer_id => new_offer.customer_id, :status_id => new_offer.status_id)
    assert offer.valid?
    assert offer.save
  end
  
  def test_validates_presence_of
    REQ_ATTR_NAMES.each do |attr_name|
      tmp_offer = NEW_OFFER.clone
      tmp_offer.delete attr_name.to_sym
      offer = Offer.new(tmp_offer)
      assert !offer.valid?, "Project should be invalid, as @#{attr_name} is invalid"
      assert offer.errors.invalid?(attr_name.to_sym), "Should be an error message for :#{attr_name}"
    end
  end

end
