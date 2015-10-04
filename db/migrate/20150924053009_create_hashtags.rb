class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :name
      t.integer :user_id
      t.string :last_printed, default: '0'
      t.timestamps null: false
    end
  end
end
