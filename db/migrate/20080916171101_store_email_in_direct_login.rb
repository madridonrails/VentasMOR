class StoreEmailInDirectLogin < ActiveRecord::Migration
  def self.up
    change_column :accounts, :direct_login, :string, :default => nil
    Account.reset_column_information
    Account.update_all("direct_login = NULL")
  end

  def self.down
    change_column :accounts, :direct_login, :boolean, :default => false
    Account.reset_column_information
    Account.update_all("direct_login = 0")
  end
end
