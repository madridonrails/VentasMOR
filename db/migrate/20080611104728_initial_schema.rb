class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name, :name_normalized
    end

    create_table :accounts do |t|
      t.string  :short_name, :null => false, :unique => true
      t.boolean :blocked, :default => false
      t.timestamps
    end

    create_table :users do |t|
      t.integer  :account_id, :null => false
      t.string   :name, :name_normalized

      # Authentication.
      t.string   :email
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at

      # Roles, non-exclusive.
      t.boolean  :administrator
      t.boolean  :salesman
      t.boolean  :accountant
      t.boolean  :engineer
      
      # Timestamps.
      t.timestamps
    end
    
    create_table :statuses do |t|
      t.integer :account_id, :null => false
      t.string  :type
      t.string  :name, :name_normalized
      t.integer :weight
      
      # Managed by acts_as_list, matters in the drop-down.
      t.integer :position
    end

    create_table :addresses do |t|
      t.string  :street1, :street2, :city, :province, :postal_code
      t.integer :country_id

      # Addresses are polymorphic.
      t.integer :addressable_id
      t.string  :addressable_type
    end

    create_table :customers do |t|
      t.integer :account_id, :null => false
      t.string  :name, :name_normalized
      t.string  :cif
      t.text    :notes
      t.timestamps
    end

    create_table :projects do |t|
      t.integer :salesman_id, :null => false, :references => :users

      # Basic fields.
      t.string  :name, :name_normalized
      t.decimal :amount, :precision => 14, :scale => 2
      t.date    :deal_date
      t.integer :customer_id
      t.string  :next_action
      t.date    :next_action_due_date
      t.text    :description

      # Each status has a weight. On creation we will assign the one of the
      # status, but the user may edit it for this particular project.
      t.integer :status_id
      t.integer :weight

      t.timestamps
    end

    create_table :invoices do |t|
      t.integer :project_id
      t.decimal :amount, :precision => 14, :scale => 2
      t.string  :number
      t.date    :date, :estimated_payment_date
      t.boolean :paid
    end    
  end

  def self.down
    puts "\n\nI don't want to sync this, please execute rake db:drop or db:migrate:reset\n\n\n"
  end
end
