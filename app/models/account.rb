# == Schema Information
# Schema version: 20080808120148
#
# Table name: accounts
#
#  id            :integer(11)     not null, primary key
#  short_name    :string(255)     not null
#  blocked       :boolean(1)
#  created_at    :datetime
#  updated_at    :datetime
#  name          :string(255)     not null
#  direct_login  :boolean(1)
#  campaign_code :string(255)
#  referer       :string(1024)
#  landing_page  :string(1024)
#

class Account < ActiveRecord::Base
  attr_accessible :short_name, :name

  has_many :users, :dependent => :destroy
  delegate :administrators, :to => :users
  delegate :salesmen, :to => :users

  has_many :offers, :through => :users
  has_many :customers, :dependent => :destroy
  has_many :statuses, :order => 'position', :dependent => :destroy
  has_many :custom_statuses
  has_one  :lost_status
  has_one  :won_status

  validates_presence_of   :name
  validates_presence_of   :short_name
  validates_uniqueness_of :short_name
  validates_exclusion_of  :short_name, :in => Config.reserved_subdomains, :message => 'ésta es una dirección reservada'
  validates_format_of     :short_name, :with => %r{\A[a-z][\-a-z\d]+\z}, :unless => lambda {|account| account.short_name.blank?}, :message => 'la dirección debe empezar por una letra y sólo puede tener caracteres alfanuméricos'
  validates_associated    :users
  
  before_create :build_default_statuses

  # These are convenience named scopes to be able to check this stuff in console.
  named_scope :signups_after_launch, :conditions => ['created_at >= ?', Date.new(2008, 9, 29)]
  named_scope :todays_signups, lambda {{:conditions => ['created_at >= ?', Date.today]}}

  def email
    administrators.map(&:email).join(', ')
  end
  
  def build_default_statuses
    custom_statuses.build(:name => "Petición", :weight => 10)
    custom_statuses.build(:name => "Presentada", :weight => 30)
    custom_statuses.build(:name => "Ganadora", :weight => 80)
    build_won_status(:name => 'Ganada', :weight => 100)
    build_lost_status(:name => 'Perdida', :weight => 0)
  end

  # See documentation of Offer#pipeline.
  def pipeline
    Offer.pipeline(self)
  end

  # See documentation of Offer#totals_pipeline.
  def totals_pipeline
    Offer.totals_pipeline(self)
  end

  # Returns the associated statuses, ordered by +position+.
  def statuses_ordered
    statuses.all(:order => 'position ASC')
  end

  # Returns the associated customers, orderd by +name_normalized+.
  def customers_ordered
    customers.all(:order => 'name_normalized ASC')
  end

  # Returns the associated salesmen, ordered by +name_normalized+.  
  def salesmen_ordered
    users.salesmen.all(:order => 'name_normalized ASC')
  end

  # Returns all won offers.
  def won_offers(options={})
    won_status.offers.all(options)
  end

  # Returns all lost offers.
  def lost_offers(options={})
    lost_status.offers.all(options)
  end

  def enable_direct_login!(user)
    update_attribute(:direct_login, user.email) if self == user.account
  end

  def disable_direct_login!
    update_attribute(:direct_login, nil)
  end
end
