class RemoveInvoicing < ActiveRecord::Migration
  def self.up
    drop_table :invoices
    remove_column :users, :accountant
    remove_column :users, :engineer
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
