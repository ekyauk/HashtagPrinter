class AddGoogleAccessTokenToUser < ActiveRecord::Migration
  def change
        add_column :users, :google_oauth_token, :string
  end
end
