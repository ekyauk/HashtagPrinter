class AddUsersHashtagsJoinTable < ActiveRecord::Migration
    def change
        create_table :users_hashtags, :id => false do |t|
        t.integer :user_id
        t.integer :hashtag_id
        end

        add_index :users_hashtags, [:user_id, :hashtag_id]

    end

    def self.down
        drop_table :users_hashtags
    end
end
