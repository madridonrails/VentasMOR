class AddDescriptionNormalizedToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :description_normalized, :text
  end

  def self.down
    remove_column :offers, :description_normalized
  end
end
