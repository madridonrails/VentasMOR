class RenameProjectToOffer < ActiveRecord::Migration
  def self.up
    rename_table :projects, :offers
  end

  def self.down
    rename_table :offers, :projects
  end
end
