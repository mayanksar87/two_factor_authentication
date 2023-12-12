# 2FA Authentication App (for authentication and authorization of user)
This web application allows you to register user and login user.It provide functionality like enable/disable 2FA(two factor authorization). It's built using Ruby 3.0.2 and utilizes RVM for Ruby version management.

## 1. Prerequisites
Before using this tool, ensure you have the following prerequisites:
- Ruby 3.0.2 installed on your system.
To install Ruby using RVM, you can follow the instructions [here](https://rvm.io/rvm/install).
- Run bundle install to install the dependencies.
   bash```
    bundle
     ```        
                    OR

You can directly run command.
bash```
 Bundle install
 ```

## 3. For Testing

Step_1: Run ruby app.rb to start server.

Step_2: Enter localhost url: http://127.0.0.1:4567

Step_3: After cloning project run "sudo -u postgres psql" command for entering in postgres terminal.

Step_4: Create database on postgres.
 
Step_5: Replace your database name in this line in app.rb.
set :database, { adapter: 'postgresql', database: 'database', username: 'developer', password: 'password',  host: 'localhost' } 

Step_6: Click on signup for registration.

Step_7: Enter email and password.

Step_8: Login with registered email and password.
 
Step_9: Enter OTP.

Step_10: After login you can enable two factor authentication.

Step_11: For reset new password click on forgot password.

Step_12: Enter Token for reset new password.