class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest
  #  <from exercise 6.35> before_save { email.downcase! }
  validates(:name,     { presence: true,
                         length: { maximum: 50 } } )
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(:email,    { presence: true, 
                         length: { maximum: 255},
                         format: { with: VALID_EMAIL_REGEX},
                         uniqueness: true } )
  has_secure_password
  validates(:password, { presence: true, 
                         length: { minimum: 6 },
                         allow_nil: true  } )

  # Returns the hash digest of a given string.  Used in creating user
  # test password_digests. 
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Returns a session token to prevent session hijacking.
  # We reuse the remember digest for convenience.
  def session_token
    remember_digest || remember
  end
  
  # Returns true if the given token mathches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Activate and account
  def activate
    self.update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # Send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  private
  
  # Converts email to downcase
  def downcase_email
    self.email = self.email.downcase
  end
  
  # Creates and assigns the activation token digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
    
  end
end