class AddDeltaToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :offers, :delta
  end
end
