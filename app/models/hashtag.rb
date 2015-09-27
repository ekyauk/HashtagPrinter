class Hashtag < ActiveRecord::Base
    has_and_belongs_to_many :users, join_table: :users_hashtags
    validates_uniqueness_of :name
    validates :name, :presence => true

    SUBSCRIPTION_CALLBACK = 'http://hashtag-printer.herokuapp.com/hashtags/callback/'

    def create_subscription(user_id)
        options = { object_id: self.name }
        begin
            Instagram.create_subscription('tag', SUBSCRIPTION_CALLBACK + user_id,'media', options)
        rescue Exception => e
            self.destroy
            puts "Instagram fail: #{e}"
        end
    end

    handle_asynchronously :create_subscription
end
