require 'securerandom'

class User < ActiveRecord::Base 
  has_secure_password 
  has_one_time_password
    
  #callback 
  after_create_commit :send_welcome_email
  before_update :send_otp_mail, if: -> { attribute_changed?(:otp) }

  #validation
  validates :email, presence: true, uniqueness: true

  def generate_otp
    SecureRandom.random_number(1000000).to_s.rjust(6, '0')
  end
  
  private

  def send_otp_mail
    ConfirmationMailer.send_otp(self)
  end

  def send_welcome_email
    ConfirmationMailer.welcome_email(self)
  end

end
  