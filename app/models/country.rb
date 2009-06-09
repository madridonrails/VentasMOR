# == Schema Information
# Schema version: 20080808120148
#
# Table name: countries
#
#  id              :integer(11)     not null, primary key
#  name            :string(255)
#  name_normalized :string(255)
#

class Country < ActiveRecord::Base
  # Returns all countries, ordered by +name_normalized+.
  def self.ordered
    all(:order => 'name_normalized ASC')
  end  

  # Returns and caches the Country instance that represents Spain.
  def self.spain
    @@spain ||= find_by_name_normalized('espana')
  end
end
