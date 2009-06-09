# == Schema Information
# Schema version: 20080808120148
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  account_id                :integer(11)     not null
#  name                      :string(255)
#  name_normalized           :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  administrator             :boolean(1)
#  salesman                  :boolean(1)
#  created_at                :datetime
#  updated_at                :datetime
#  color                     :string(255)
#

class User < ActiveRecord::Base
  # Role flags are protected by the controller, we allow mass-assignment.
  attr_accessible :name, :email, :password, :administrator, :salesman
  attr_accessor :password

  belongs_to :account

  validates_presence_of     :name
  validates_presence_of     :email
  validates_uniqueness_of   :email, :case_sensitive => false, :scope => 'account_id'
  validates_length_of       :email, :within => 3..100,   :unless => lambda {|user| user.email.blank?}
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => lambda {|user| user.password_required? && !user.password.blank?}

  before_create :assign_color
  before_save :encrypt_password

  has_many :offers, :foreign_key => 'salesman_id', :dependent => :destroy
  reindexes :offers, :if => :name_changed?

  named_scope :administrators, :conditions => {:administrator => true}
  named_scope :salesmen, :conditions => {:salesman => true}

  def validate
    unless administrator? || salesman?
      errors.add(:salesman, "al menos uno de los dos roles debe estar seleccionado")
    end
  end

  def to_param
    "#{id}-#{VentasgemUtils.normalize_for_url(name)}"
  end
  
  def pipeline
    Offer.pipeline(self)
  end
  
  def totals_pipeline
    Offer.totals_pipeline(self)
  end

  # Salesmen with offers are not destroyable, and the application needs at
  # least an administrator. The rest of users are destroyable. This method is
  # a convenience test that assists +can_destroy_user?+ to help build views and
  # so on, but it may obviously be subject of race conditions.
  def destroyable?
    administrator? ? User.count(:conditions => {:administrator => true}) > 1 : true
  end

  # Can edit this particular user?
  def can_edit_user?(user)
    administrator? or (self == user)
  end

  # Can destroy this particular user?
  def can_destroy_user?(user)
    administrator? and (self != user) and user.destroyable?
  end

  def can_see_offer?(offer)
    administrator? || self == offer.salesman
  end

  # We assign a unique color to the user modulus the obvious race condition.
  # Note that all in all collisions are extremely unlikely to happen.
  def assign_color
    self.color = VentasgemUtils.random_color(account.users.map(&:color))
    logger.info("assigned random color #{color} to user #{name} with ID #{id}")
  end
  protected :assign_color

  def chpass
    update_attribute(:password, VentasgemUtils.random_password)
  end

  ### -------------------------------------------------------------------------
  ##
  #   Authentication
  ##
  ### -------------------------------------------------------------------------

  # Authenticates a user by their email and unencrypted password.
  # Returns the user or +nil+.
  def self.authenticate(account, email, password)
    u = account.users.find_by_email(email) # user needed to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  protected :encrypt_password
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
