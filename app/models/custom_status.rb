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

class CustomStatus < Status
  # We assign a unique color to the user modulus the obvious race condition. Note
  # that all in all collisions are extremely unlikely to happen.
  def assign_color
    self.color = VentasgemUtils.random_color(account.statuses.map(&:color))
    logger.info("assigned random color #{color} to custom status #{name} with ID #{id}")
  end
  protected :assign_color
end
