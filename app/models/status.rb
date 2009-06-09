# == Schema Information
# Schema version: 20080808120148
#
# Table name: statuses
#
#  id              :integer(11)     not null, primary key
#  account_id      :integer(11)     not null
#  type            :string(255)
#  name            :string(255)
#  name_normalized :string(255)
#  weight          :integer(11)
#  position        :integer(11)
#  color           :string(255)
#

# This is the root of a STI.
class Status < ActiveRecord::Base
  attr_accessible :name, :weight

  belongs_to :account
  acts_as_list :scope => :account
  has_many :offers, :dependent => :nullify
  reindexes :offers, :if => :name_changed?

  # This callback has to be implemented by children.
  before_create :assign_color

  def to_param
    "#{id}-#{VentasgemUtils.normalize_for_url(name)}"
  end

  def editable?
    true
  end

  def can_be_destroyed?
    offers.empty?
  end
end
