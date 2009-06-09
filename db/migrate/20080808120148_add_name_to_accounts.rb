class AddNameToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :name, :string, :null => false
    add_column :accounts, :direct_login, :boolean
    add_column :accounts, :campaign_code, :string
    add_column :accounts, :referer, :string, :limit => 1024
    add_column :accounts, :landing_page, :string, :limit => 1024
  end

  def self.down
    remove_column :accounts, :name
    remove_column :accounts, :direct_login
    remove_column :accounts, :campaign_code
    remove_column :accounts, :referer
    remove_column :accounts, :landing_page
  end
end
