class AddPrinterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :printer_id, :string
  end
end
