class AddTokenColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :refresh_token, :string
    add_column :users, :token_expires, :integer
  end
end
