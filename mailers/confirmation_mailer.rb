
require 'pony'
require 'sinatra'
require 'erb'

configure :development do
  Pony.override_options = { :via => LetterOpener::DeliveryMethod, :via_options => { :location => File.expand_path('../tmp/letter_opener', __FILE__) } }
end

class ConfirmationMailer
  include ERB::Util
  def self.welcome_email(user)
    template_path = File.expand_path('../views/welcome_email.erb', __FILE__)
    erb_template = ERB.new(File.read(template_path))
    email_body = erb_template.instance_eval { result(binding) }.to_s
    Pony.mail({
      to: user.email,
      subject: 'Welcome to Our App',
      body: email_body
    })
  end

  def self.send_otp(email, otp)
    template_path = File.expand_path('../views/send_otp.erb', __FILE__)
    erb_template = ERB.new(File.read(template_path))
    email_body = erb_template.instance_eval { result(binding) }.to_s
    Pony.mail({
      to: email,
      subject: 'Your OTP for Two-Factor Authentication',
      body: email_body
    })
  end

  def self.password_reset_email(user,token)
    template_path = File.expand_path('../views/reset_password.erb', __FILE__)
    erb_template = ERB.new(File.read(template_path))
    email_body = erb_template.instance_eval { result(binding) }.to_s
    Pony.mail({
      to: user.email,
      subject: ' Your Reset Password Email',
      body: email_body
    })
  end
end
