class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :instagram]
  has_and_belongs_to_many :hashtags, join_table: :users_hashtags
  def self.from_omniauth(access_token)
      data = access_token.info
      user = User.where(:email => data["email"]).first
      unless user
          user = User.create(name: data["name"],
             email: data["email"],
             password: Devise.friendly_token[0,20]
          )
      end

      user
  end

  def renew_google_access_token
    puts 'about to renew token'
    uri = URI("https://www.googleapis.com/oauth2/v3/token")
    fields = {
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        refresh_token: self.google_refresh_token,
        grant_type: self.google_refresh_token
    }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(fields)
    res = http.request(req)
    puts res
    res_hash = JSON.parse(res.body)
    self.google_oauth_token = res_hash['access_token']
    self.save
  end

end
