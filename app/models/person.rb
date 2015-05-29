class Person < ActiveRecord::Base

  # never ever change the order of the properties! just add at the end!
  bitmask :roles, :as => [ :admin, :owner, :leaser ]
  bitmask :status, :as => [ :deleted, :active, :pending, :doubted ]

  validates_inclusion_of :sex, :in => %w{m f}

  attr_accessor :password
  before_save :encrypt_password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  #validates_presence_of :email, :on => :create
  #validates_presence_of :username, :on => :create
  #validates_uniqueness_of :email
  #validates_uniqueness_of :username

  def add_role
    person
  end

  def self.authenticate_by_email(email, password)
    person = find_by_email(email)
    if person && person.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      person
    else
      nil
    end
  end
  
  def self.authenticate_by_username(username, password)
    person = find_by_username(username)
    if person && person.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      person
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end
