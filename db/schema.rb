# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081118180224) do

  create_table "accounts", :force => true do |t|
    t.string   "short_name",                                       :null => false
    t.boolean  "blocked",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                             :null => false
    t.string   "direct_login"
    t.string   "campaign_code"
    t.string   "referer",       :limit => 1024
    t.string   "landing_page",  :limit => 1024
  end

  create_table "addresses", :force => true do |t|
    t.string  "street1"
    t.string  "street2"
    t.string  "city"
    t.string  "province"
    t.string  "postal_code"
    t.integer "country_id",       :limit => 11
    t.integer "addressable_id",   :limit => 11
    t.string  "addressable_type"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
    t.string "name_normalized"
  end

  create_table "customers", :force => true do |t|
    t.integer  "account_id",      :limit => 11, :null => false
    t.string   "name"
    t.string   "name_normalized"
    t.string   "cif"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact"
    t.string   "email"
    t.string   "fax"
    t.string   "phone"
  end

  create_table "offers", :force => true do |t|
    t.integer  "salesman_id",            :limit => 11,                                                   :null => false
    t.string   "name"
    t.string   "name_normalized"
    t.decimal  "amount",                               :precision => 14, :scale => 2
    t.date     "deal_date"
    t.integer  "customer_id",            :limit => 11
    t.string   "next_action"
    t.date     "next_action_due_date"
    t.text     "description"
    t.integer  "status_id",              :limit => 11
    t.integer  "weight",                 :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description_normalized"
    t.boolean  "delta",                                                               :default => false
  end

  create_table "statuses", :force => true do |t|
    t.integer "account_id",      :limit => 11, :null => false
    t.string  "type"
    t.string  "name"
    t.string  "name_normalized"
    t.integer "weight",          :limit => 11
    t.integer "position",        :limit => 11
    t.string  "color"
  end

  create_table "users", :force => true do |t|
    t.integer  "account_id",                :limit => 11, :null => false
    t.string   "name"
    t.string   "name_normalized"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "administrator"
    t.boolean  "salesman"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
  end

end
