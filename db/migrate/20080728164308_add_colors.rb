class AddColors < ActiveRecord::Migration
  def self.up
    add_column :statuses, :color, :string
    add_column :users, :color, :string
  end

  def self.down
    remove_column :users, :color
    remove_column :statuses, :color
  end
end
