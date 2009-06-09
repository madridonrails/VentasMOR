# == Schema Information
# Schema version: 20080808120148
#
# Table name: customers
#
#  id              :integer(11)     not null, primary key
#  account_id      :integer(11)     not null
#  name            :string(255)
#  name_normalized :string(255)
#  cif             :string(255)
#  notes           :text
#  created_at      :datetime
#  updated_at      :datetime
#

class Customer < ActiveRecord::Base
  attr_accessible :name, :contact, :phone, :email, :fax, :cif, :notes

  belongs_to :account
  has_many :offers, :dependent => :destroy
  reindexes :offers, :if => :name_changed?

  has_one  :address, :as => :addressable, :dependent => :destroy

  validates_presence_of :name
  validates_associated :address

  def to_param
    "#{id}-#{VentasgemUtils.normalize_for_url(name)}"
  end
  
  def can_be_destroyed?
    offers.empty?
  end
end
