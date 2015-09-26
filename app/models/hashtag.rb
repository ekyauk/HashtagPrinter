class Hashtag < ActiveRecord::Base
    has_and_belongs_to_many :user
    validates_uniqueness_of :name
    validates :name, :presence => true

end
