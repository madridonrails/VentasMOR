# == Schema Information
# Schema version: 20080808120148
#
# Table name: offers
#
#  id                     :integer(11)     not null, primary key
#  salesman_id            :integer(11)     not null
#  name                   :string(255)
#  name_normalized        :string(255)
#  amount                 :decimal(14, 2)
#  deal_date              :date
#  customer_id            :integer(11)
#  next_action            :string(255)
#  next_action_due_date   :date
#  description            :text
#  status_id              :integer(11)
#  weight                 :integer(11)
#  created_at             :datetime
#  updated_at             :datetime
#  description_normalized :text
#  delta                  :boolean(1)
#

class Offer < ActiveRecord::Base
  attr_accessible :name, :amount, :deal_date, :deal_date_as_string
  attr_accessible :next_action, :next_action_due_date, :next_action_due_date_as_string
  attr_accessible :description, :weight

  belongs_to :salesman, :class_name => 'User', :foreign_key => 'salesman_id'
  delegate :account, :to => :salesman

  belongs_to :customer
  belongs_to :status

  validates_presence_of :name
  validates_presence_of :amount
  validates_presence_of :customer_id
  validates_presence_of :salesman_id
  validates_presence_of :deal_date
  validates_presence_of :status_id

  l10n_decimal :amount
  l10n_date    :deal_date, :next_action_due_date

  # These are the offers that have a deal date in the future. This is a dynamic
  # named scope because Date.today needs to be evaluated on each call.
  named_scope :current, lambda { { :conditions => ['deal_date >= ?', Date.today] } }

  # These are the offers that have a deal date in the past. This is a dynamic
  # named scope because Date.today needs to be evaluated on each call.
  named_scope :old, lambda { { :conditions => ['deal_date < ?', Date.today] } }

  # These are the offers that have been either won or lost.
  named_scope :closed, :include => :status, :conditions => "statuses.type = 'WonStatus' OR statuses.type = 'LostStatus'"

  # These are the offers with a custom status, no matter their deal date.
  named_scope :open, :include => :status, :conditions => "statuses.type <> 'WonStatus' AND statuses.type <> 'LostStatus'"

  def to_param
    "#{id}-#{VentasgemUtils.normalize_for_url(name)}"
  end

  # Predicate that says whether a offer has been lost.
  def lost?
    status && status.is_a?(LostStatus)
  end

  # Predicate that says whether a offer has been won.
  def won?
    status && status.is_a?(WonStatus)
  end

  # Predicate that says whether this offer has a deal date in the future.
  def current?
    deal_date >= Date.today
  end

  # Predicate that says whether this offer has been either won or lost.
  def open?
    !closed?
  end
  
  # Not <tt>open?</tt>.
  def closed?
    won? or lost?
  end

  def overdue_closing?
    open? && deal_date < Date.today
  end

  # Returns the logical weight associated to this offer.
  #
  # This may be a hard-coded value for won and lost offers, a default, or a user
  # defined value. You get the final value no matter what.
  def weight
    if closed?
      won? ? 100 : 0
    elsif w = read_attribute(:weight)
      w
    elsif status
      status.weight
    else
      raise "there's a offer without a well-defined weight, this is a bug"
    end
  end

  # Predicate that says whether a offer has a user defined weight. This can only
  # happen for open offers.
  def has_user_defined_weight?
    !closed? && read_attribute(:weight)
  end

  # Won offers have a weight of 100, lost offers have a weight of 0, the rest of
  # the offers have the weight of their status, unless an explicit weight is
  # set.
  def weighted_amount
    return if not amount
    amount*weight/100
  end
  
  # Given an Account or User as +scope+, returns an array with their current
  # offers, thus including lost offers.
  def self.pipeline(scope)
    scope.offers.current.all(:include => :status)
  end

  # Given an Account or User as +scope+, returns and array of two elements,
  # their pipeline total and pipeline weighted total respectively.
  def self.totals_pipeline(scope)
    total = weighted_total = 0
    pipeline(scope).each do |offer|
      total += offer.amount
      weighted_total += offer.weighted_amount
    end
    return [total, weighted_total]
  end

  # ---
  #
  # Convenience methods to prevent ID injection
  #
  # ---

  def assign_protected_stuff(account, user, params)
    if all_ids_look_ok(account, user, params)
      if user.administrator?
        self.salesman_id = params[:salesman_id] if params.key?(:salesman_id)
      else
        # If this guy is not an admin he can only assign offers to himself.
        self.salesman = user
      end
      self.customer_id = params[:customer_id] if params.key?(:customer_id)
      self.status_id   = params[:status_id]   if params.key?(:status_id)
    end
  end

  # This method is used to prevent ID injection, not to prevent race conditions.
  def all_ids_look_ok(account, user, params)
    [[:salesman_id, :salesmen], [:customer_id, :customers], [:status_id, :statuses]].each do |k, c|
      if params.key?(k)
        # Ensure this IDs belong to this account as far as injection is concerned.
        return false unless account.send(c).exists?(params[k])
      end
    end
    return true
  end
  private :all_ids_look_ok

  # ---
  # 
  # Searching
  # 
  # ---

  define_index do
    # fields
    indexes description_normalized,   :as => :description,   :sortable => true
    indexes name_normalized,          :as => :name,          :sortable => true
    indexes customer.name_normalized, :as => :customer_name, :sortable => true
    indexes salesman.name_normalized, :as => :salesman_name, :sortable => true
    indexes status.name_normalized,   :as => :status_name,   :sortable => true
    
    # attributes
    has amount
    has salesman(:id), :as => :salesman_id
    # Pass a :type to let Thinking Sphinx call UNIX_TIMESTAMP() on it.
    # Admittedly shameless and dirty, but the only possible way to have a
    # sortable date attribute as of this writing.
    has deal_date, :type => :datetime
    has salesman.account(:id), :as => :account_id
    
    # enable delta index
    set_property :delta => true
  end
end
