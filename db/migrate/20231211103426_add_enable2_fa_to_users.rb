class AddEnable2FaToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :enable_2fa, :boolean, default: false
  end
end
