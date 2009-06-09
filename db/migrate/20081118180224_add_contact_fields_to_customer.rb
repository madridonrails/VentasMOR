class AddContactFieldsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :contact, :string
    add_column :customers, :email, :string
    add_column :customers, :fax, :string
    add_column :customers, :phone, :string
  end

  def self.down
    remove_column :customers, :phone
    remove_column :customers, :fax
    remove_column :customers, :email
    remove_column :customers, :contact
  end
end
