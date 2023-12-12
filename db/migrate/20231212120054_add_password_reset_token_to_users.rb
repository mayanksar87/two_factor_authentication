class AddPasswordResetTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_reset_token, :string
  end
end
