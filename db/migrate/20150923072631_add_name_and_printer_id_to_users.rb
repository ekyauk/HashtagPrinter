class AddNameAndPrinterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :printer_id, :string
  end
end
