require 'sinatra'
require 'sinatra/flash'
require 'rqrcode'
require 'sinatra/activerecord'
require 'securerandom'
require 'bcrypt'
require 'byebug'
require 'letter_opener'
require 'active_model_otp'

# Load the User model
require_relative 'models/user'
require_relative 'mailers/confirmation_mailer'
require_relative 'config/environments/development'


set :database, { adapter: 'postgresql', database: 'database', username: 'developer', password: 'password',  host: 'localhost' }

ENV['SINATRA_ENV'] ||= 'development'


enable :sessions  
set :session_secret, "7f31e01478ef476bda83d82de0ca40a89151df1c84d435c5660ccbbe0d563805"

helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end


get '/' do 
  @user = current_user
  erb :index
end  

get '/signup' do
  erb :'users/new'
end

post '/signup' do
  @user = User.new(params[:user])
  if @user.save
    ConfirmationMailer.welcome_email(@user)
    redirect 'login'
  else
    flash[:error] = "Error- please try to create an account again."
    erb :'users/new'
  end
end

get '/login' do 
  erb :login
end

get '/logout' do 
  session.clear
  redirect '/'
end

get '/forgot_password' do
  erb :forgot_password
end

get '/otp' do
  erb :otp
end

post '/login' do
  user = User.find_by(email: params[:session][:email])
  
  if user && user.authenticate(params[:session][:password])
    session[:user_id] = user.id
    session[:otp_passed] = false
    
    if !user.verified || user.otp_enabled
      user.update(verified: true)
      session[:otp] = user.generate_otp
      ConfirmationMailer.send_otp(user.email, session[:otp])
      redirect '/otp_authenticate'
    else
      redirect '/'
    end
  else
    flash[:error] = "Email or password is invalid!"
    redirect '/login'
  end
end

post '/forgot_password' do
  email = params['email']
  user = User.find_by(email: email)

  if user
    token = SecureRandom.hex(10)
    user.update!(password_reset_token: token)
    ConfirmationMailer.password_reset_email(user,token)
    redirect '/forgot_token_authenticate'
  else
    flash[:error] = "Email is invalid!"
    redirect '/forgot_password'
  end
end

get '/forgot_token_authenticate' do
   erb :forgot_token_authenticate
end

post '/verify_forgot_password_token' do
  token = params[:password_reset_token]
  @user = User.find_by(password_reset_token: token)
  if  @user && @user.password_reset_token == token
    redirect "/new_password?user_id=#{@user.id}"
  else
    flash[:error] = "Invalid Token. Please try again."
    redirect '/forgot_token_authenticate'
  end
end

get '/new_password' do
  user_id = params[:user_id]
  @user = User.find_by(id: user_id)
  if @user
    erb :new_password
  else
    flash[:error] = "User not found. Please try again."
    redirect '/forgot_token_authenticate'
  end
end

post '/reset_password' do 
  user_id = params['user_id']
  @user = User.find_by(id: user_id)
  if @user
    new_password = params['user']['password']
    @user.update(password: new_password)

    @user.update(password_reset_token: nil)

    redirect '/'
  else
    flash[:error] = "User not found. Please try again."
    redirect '/forgot_token_authenticate'
  end
end

get '/otp_authenticate' do
  erb :otp_authenticate
end

post '/verify_otp' do
  if session[:otp] == params[:otp]
    session[:otp_passed] = true
    redirect '/'
  else
    flash[:error] = "Invalid OTP. Please try again."
    redirect '/otp_authenticate'
  end
end

post '/otp' do
  otp_code = params[:otp_code]
  
  if @user.authenticate_otp(otp_code)
    session[:otp_passed] = true
    redirect '/'
  else
    flash[:error] = "Invalid OTP code"
    redirect '/otp'
  end
end

post '/add_otp' do
  @user = current_user
  otp_code = params[:otp_code]
  
  if @user.authenticate_otp(otp_code, drift: 60)
    @user.update!(otp_enabled: true)
    redirect '/'
  else
    flash[:error] = "Invalid OTP code"
    redirect '/enable_2fa'
  end
end

get '/enable_2fa' do
  @user = current_user
  erb :enable_2fa
end


get '/disable_2fa' do
  @user = current_user
  @user.update(otp_enabled: false)
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  session[:otp_passed] = false
  redirect '/'
end


get '/qr' do
  @user = current_user
  totp = ROTP::TOTP.new(@user.otp_secret_key, issuer: "OTP Test")
  qrcode = RQRCode::QRCode.new(totp.provisioning_uri(@user.email))
  
  content_type 'image/png'
  headers['Content-Disposition'] = 'inline'
  qrcode.as_png(size: 500).to_s
end



