class AddSaveToGdriveToUser < ActiveRecord::Migration
  def change
    add_column :users, :save_to_gdrive, :boolean
  end
end
