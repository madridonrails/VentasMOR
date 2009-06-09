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

class WonStatus < Status
  def editable?
    false
  end

  # The application needs a won status that is always there and is distinguished.
  def can_be_destroyed?
    false
  end

  def assign_color
    self.color = '#00FF00'
  end
  protected :assign_color
end
