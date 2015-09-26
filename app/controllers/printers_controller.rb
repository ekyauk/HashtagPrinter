require 'net/http'
require 'json'

class PrintersController < ApplicationController

    def index
        access_token = session[:google_oauth_token]
        uri = URI("https://www.google.com/cloudprint/search")
        params = {
            :client_id => ENV['GOOGLE_CLIENT_ID'],
            :access_token => access_token
        }

        uri.query = URI.encode_www_form(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        req.add_field('X-CloudPrint-Proxy', '0.0.0.0')
        res = http.request(req)
        puts 'atwfytunwfyutnafwuyttnafywun'
        if res.code == '200'
            puts 'SUCCESSSSSS'
            @printer_info = JSON.parse(res.body)
        end
        puts res.body
    end

end
